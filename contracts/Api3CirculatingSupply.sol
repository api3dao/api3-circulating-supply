//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IApi3Pool.sol";
import "./interfaces/ITimelockManager.sol";

contract Api3CirculatingSupply is Ownable {
    event SetVestingAddresses(address[] vestingAddresses);

    address public constant API3_TOKEN =
        0x0b38210ea11411557c13457D4dA7dC6ea731B88a;
    address public constant API3_POOL =
        0x6dd655f10d4b9E242aE186D9050B68F725c76d76;
    address public constant TIMELOCK_MANAGER =
        0xFaef86994a37F1c8b2A5c73648F07dd4eFF02baA;
    address public constant TIMELOCK_MANAGER_REVERSIBLE =
        0x310BBf92A36031F778C32FEaCa458251FD36F451;
    address public constant V1_TREASURY =
        0xe7aF7c5982e073aC6525a34821fe1B3e8E432099;
    address public constant PRIMARY_TREASURY =
        0xD9F80Bdb37E6Bad114D747E60cE6d2aaF26704Ae;
    address public constant SECONDARY_TREASURY =
        0x556ECbb0311D350491Ba0EC7E019c354D7723CE0;

    IERC20 public immutable api3Token;
    IApi3Pool public immutable api3Pool;
    ITimelockManager public immutable timelockManager;
    address[] public vestingAddresses;

    constructor() {
        api3Token = IERC20(API3_TOKEN);
        api3Pool = IApi3Pool(API3_POOL);
        timelockManager = ITimelockManager(TIMELOCK_MANAGER);
    }

    function setVestingAddresses(address[] memory _vestingAddresses)
        external
        onlyOwner()
    {
        vestingAddresses = _vestingAddresses;
        emit SetVestingAddresses(_vestingAddresses);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return api3Token.totalSupply() - getTotalLocked();
    }

    function getTotalLocked() public view returns (uint256) {
        return getTimelocked() + getLockedByGovernance();
    }

    function getTimelocked() public view returns (uint256) {
        return getLockedRewards() + getLockedVestings();
    }

    function getLockedByGovernance()
        public
        view
        returns (uint256)
    {
        // The reversible timelock manager funds are treated as being locked by
        // governance because they are not stakeable and are governed over by
        // DAOv1
        return api3Token.balanceOf(V1_TREASURY) +
            api3Token.balanceOf(PRIMARY_TREASURY) +
            api3Token.balanceOf(SECONDARY_TREASURY) + 
            api3Token.balanceOf(TIMELOCK_MANAGER_REVERSIBLE);
    }

    function getLockedRewards()
        public
        view
        returns (uint256 totalLockedRewards)
    {
        uint256 currentEpoch = block.timestamp / api3Pool.EPOCH_LENGTH();
        uint256 oldestLockedEpoch = currentEpoch -
            api3Pool.REWARD_VESTING_PERIOD() +
            1;
        if (oldestLockedEpoch < api3Pool.genesisEpoch() + 1) {
            oldestLockedEpoch = api3Pool.genesisEpoch() + 1;
        }
        for (
            uint256 indEpoch = currentEpoch;
            indEpoch >= oldestLockedEpoch;
            indEpoch--
        ) {
            IApi3Pool.Reward memory lockedReward = api3Pool.epochIndexToReward(
                indEpoch
            );
            if (lockedReward.atBlock != 0) {
                totalLockedRewards += lockedReward.amount;
            }
        }
    }

    function getLockedVestings()
        public
        view
        returns (uint256 totalLockedVestings)
    {
        for (
            uint256 indVesting = 0;
            indVesting < vestingAddresses.length;
            indVesting++
        ) {
            ITimelockManager.Timelock memory timelock = timelockManager
            .timelocks(vestingAddresses[indVesting]);
            if (block.timestamp <= timelock.releaseStart) {
                totalLockedVestings += timelock.totalAmount;
            } else if (block.timestamp >= timelock.releaseEnd) {
                continue;
            } else {
                uint256 totalTime = timelock.releaseEnd - timelock.releaseStart;
                uint256 passedTime = block.timestamp - timelock.releaseStart;
                uint256 unlocked = (timelock.totalAmount * passedTime) /
                    totalTime;
                totalLockedVestings += timelock.totalAmount - unlocked;
            }
        }
    }
}

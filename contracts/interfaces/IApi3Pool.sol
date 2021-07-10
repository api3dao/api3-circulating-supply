//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IApi3Pool {
    struct Reward {
        uint32 atBlock;
        uint224 amount;
        uint256 totalSharesThen;
        uint256 totalStakeThen;
    }

    function EPOCH_LENGTH() external view returns (uint256);

    function REWARD_VESTING_PERIOD() external view returns (uint256);

    function genesisEpoch() external view returns (uint256);

    function epochIndexToReward(uint256) external view returns (Reward memory);
}

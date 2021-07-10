//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface ITimelockManager {
    struct Timelock {
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 releaseStart;
        uint256 releaseEnd;
    }

    function timelocks(address) external view returns (Timelock memory);
}

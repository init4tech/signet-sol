// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

contract TestNop is Test {
    /// @notice Prevents foundry from complaining about no tests in CI.
    function test_nop() external pure returns (bool) {
        return true;
    }
}


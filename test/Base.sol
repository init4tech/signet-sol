// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {ParmigianaConstants} from "../src/chains/Parmigiana.sol";

contract ParmigianaTest is Test {
    constructor() {
        vm.chainId(ParmigianaConstants.ROLLUP_CHAIN_ID);
    }
}


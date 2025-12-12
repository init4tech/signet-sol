// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {PecorinoConstants} from "../src/chains/Pecorino.sol";

contract PecorinoTest is Test {
    constructor() {
        vm.chainId(PecorinoConstants.ROLLUP_CHAIN_ID);
    }
}


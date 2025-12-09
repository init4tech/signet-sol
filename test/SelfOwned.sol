// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SimpleERC20} from "simple-erc20/SimpleERC20.sol";

import {PecorinoTest} from "./Base.sol";
import {SignetL2} from "../src/l2/Signet.sol";
import {AddressAliasHelper} from "../src/vendor/AddressAliasHelper.sol";

contract SelfOwnedToken is SignetL2, SimpleERC20 {
    constructor() SimpleERC20(aliasedSelf(), "My Token", "MTK", 18) {
        assert(HOST_WETH != address(0));
    }
}

contract TestSelfOwned is PecorinoTest {
    SelfOwnedToken token;

    constructor() {
        token = new SelfOwnedToken();
    }

    function test_ownerIsSelfOnL1() public view {
        assertEq(token.owner(), AddressAliasHelper.applyL1ToL2Alias(address(token)));
    }
}

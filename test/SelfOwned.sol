// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SimpleERC20} from "simple-erc20/SimpleERC20.sol";

import {ParmigianaTest} from "./Base.sol";
import {SignetL2} from "../src/l2/Signet.sol";
import {SelfOwned} from "../src/l2/SelfOwned.sol";
import {AddressAliasHelper} from "../src/vendor/AddressAliasHelper.sol";

contract SelfOwnedNothing is SelfOwned {
    constructor() {}
}

contract SelfOwnedToken is SignetL2, SimpleERC20 {
    constructor() SimpleERC20(aliasedSelf(), "My Token", "MTK", 18) {
        assert(HOST_WETH != address(0));
    }
}

contract TestSelfOwned is ParmigianaTest {
    SelfOwnedToken token;

    SelfOwnedNothing nothing;

    constructor() {
        token = new SelfOwnedToken();
        nothing = new SelfOwnedNothing();
    }

    function test_tokenOwnerIsSelfOnL1() public view {
        assertEq(token.owner(), AddressAliasHelper.applyL1ToL2Alias(address(token)));
    }

    function test_nothingOwnerIsSelfOnL1() public view {
        assertEq(nothing.owner(), AddressAliasHelper.applyL1ToL2Alias(address(nothing)));
    }
}

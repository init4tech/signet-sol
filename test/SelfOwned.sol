// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BurnMintERC20} from "../src/vendor/BurnMintERC20.sol";

import {PecorinoTest} from "./Base.sol";

import {SignetL2} from "../src/l2/Signet.sol";
import {SelfOwned} from "../src/l2/SelfOwned.sol";
import {AddressAliasHelper} from "../src/vendor/AddressAliasHelper.sol";

contract SelfOwnedNothing is SelfOwned {
    constructor() {}
}

contract SelfOwnedToken is SignetL2, BurnMintERC20 {
    constructor() BurnMintERC20("My Token", "MTK", 18, 0, 0) {
        assert(HOST_WETH != address(0));
        s_ccipAdmin = aliasedSelf();
    }
}

contract TestSelfOwned is PecorinoTest {
    SelfOwnedToken token;

    SelfOwnedNothing nothing;

    constructor() {
        token = new SelfOwnedToken();
        nothing = new SelfOwnedNothing();
    }

    function test_tokenOwnerIsSelfOnL1() public view {
        assertEq(token.getCCIPAdmin(), AddressAliasHelper.applyL1ToL2Alias(address(token)));
    }

    function test_nothingOwnerIsSelfOnL1() public view {
        assertEq(nothing.owner(), AddressAliasHelper.applyL1ToL2Alias(address(nothing)));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SignetL1} from "./Signet.sol";

abstract contract SignetL1Ephemeral is SignetL1 {
    function selfOnL2() internal view override returns (address) {
        return address(this);
    }
}

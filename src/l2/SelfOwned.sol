// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {SignetL2} from "./Signet.sol";

abstract contract SelfOwned is SignetL2, Ownable {
    constructor() {
        Ownable(aliasedSelf());
    }
}

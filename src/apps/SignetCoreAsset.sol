// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BridgeL2} from "./Bridge.sol";

contract SignetCoreAsset is BridgeL2 {
    constructor(
        address _hostAsset,
        address _hostPassageAdmin,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) BridgeL2(_hostAsset, HOST_PASSAGE, _name, _symbol, _decimals) {
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _hostPassageAdmin);
        _grantRole(MINTER_ROLE, TOKEN_MINTER);
    }
}

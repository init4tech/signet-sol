// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SimpleERC20} from "simple-erc20/SimpleERC20.sol";

import {SignetL2} from "../l2/Signet.sol";

abstract contract BridgeL2 is SignetL2, SimpleERC20 {
    address immutable HOST_ASSET;
    address immutable HOST_BANK;

    constructor(
        address _hostAsset,
        address _hostBank,
        address _initialOwner,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) SimpleERC20(_initialOwner, _name, _symbol, _decimals) {
        HOST_ASSET = _hostAsset;
        HOST_BANK = _hostBank;
    }

    function _bridgeIn(address recipient, uint256 amount, RollupOrders.Input[] memory inputs) internal virtual {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_ASSET, amount, HOST_BANK);

        ORDERS.initiate(block.timestamp, inputs, outputs);

        _mint(recipient, amount);
    }

    function bridgeIn(address recipient, uint256 amount) public virtual {
        _bridgeIn(recipient, amount, new RollupOrders.Input[](0));
    }

    function _bridgeOut(address recipient, uint256 amount, RollupOrders.Input[] memory inputs) internal virtual {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_ASSET, amount, recipient);

        ORDERS.initiate(block.timestamp, inputs, outputs);

        _burn(msg.sender, amount);
    }

    function bridgeOut(address recipient, uint256 amount) public virtual {
        _bridgeOut(recipient, amount, new RollupOrders.Input[](0));
    }
}

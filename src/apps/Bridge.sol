// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SimpleERC20} from "simple-erc20/SimpleERC20.sol";

import {SignetL2} from "../l2/Signet.sol";

abstract contract BridgeL2 is SignetL2, SimpleERC20 {
    /// @notice The address of the asset on the host chain.
    address immutable HOST_ASSET;
    /// @notice The address of the bank on the host chain. The bank holds the
    ///         asset while tokens are bridged into the rollup.
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

    /// @notice Bridges assets into the rollup for a given recipient.
    function _bridgeIn(address recipient, uint256 amount, RollupOrders.Input[] memory inputs) internal virtual {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_ASSET, amount, HOST_BANK);

        ORDERS.initiate(block.timestamp, inputs, outputs);

        _mint(recipient, amount);
    }

    /// @notice Bridges assets into the rollup for a given recipient.
    function bridgeIn(address recipient, uint256 amount) public virtual {
        _bridgeIn(recipient, amount, new RollupOrders.Input[](0));
    }

    /// @notice Burn asset on L2, and create an order to bridge out asset to
    /// L1. If the order is not filled, the asset will not be burned.
    ///
    /// This transaction should be paired with some off-chain logic that fills
    /// orders from the L1 bank.
    function _bridgeOut(address recipient, uint256 amount, RollupOrders.Input[] memory inputs) internal virtual {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_ASSET, amount, recipient);

        ORDERS.initiate(block.timestamp, inputs, outputs);

        _burn(msg.sender, amount);
    }

    /// @notice Burn asset on L2, and create an order to bridge out asset to
    /// L1. If the order is not filled, the asset will not be burned.
    ///
    /// This transaction should be paired with some off-chain logic that fills
    /// orders from the L1 bank.
    function bridgeOut(address recipient, uint256 amount) public virtual {
        _bridgeOut(recipient, amount, new RollupOrders.Input[](0));
    }
}

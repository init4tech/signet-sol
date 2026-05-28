// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HostOrders} from "zenith/src/orders/HostOrders.sol";
import {Passage} from "zenith/src/passage/Passage.sol";

/// @title GoudaConstants
/// @author init4
/// @notice Constants for the Gouda testnet.
/// @dev Gouda runs on the Parmigiana host chain, so HOST_CHAIN_ID matches
///      Parmigiana's. Rollup chain ID and on-host contract deployments are
///      gouda-specific. Used by `SignetL2` when block.chainid == ROLLUP_CHAIN_ID.
library GoudaConstants {
    /// @notice The Gouda host chain ID (shared with Parmigiana).
    uint32 constant HOST_CHAIN_ID = 3151908;
    /// @notice The Gouda Rollup chain ID.
    uint32 constant ROLLUP_CHAIN_ID = 792669;

    /// @notice The Passage contract for the Gouda host chain.
    Passage constant HOST_PASSAGE = Passage(payable(0x57348c54e3F89097579dFcD4F5d2700ca2EB1906));

    /// @notice The HostOrders contract for the Gouda host chain.
    HostOrders constant HOST_ORDERS = HostOrders(0x5C5cd1F1c35227b14F6A94c6e05347403F4C963E);

    /// USDC token for the Gouda host chain.
    address constant HOST_USDC = 0x6A27cc6968b1d08cd04a656075cc25905156827E;
    /// USDT token for the Gouda host chain.
    address constant HOST_USDT = 0x3Aad2B8D721bB2F7F79356515D15AAd3F8d6a32d;
    /// WBTC token for the Gouda host chain.
    address constant HOST_WBTC = 0x260fDcb6e6e2c1C5f96647ee0FaE34E7E92e6f28;
    /// WETH token for the Gouda host chain.
    address constant HOST_WETH = 0xD1278f17e86071f1E658B656084c65b7FD3c90eF;
}

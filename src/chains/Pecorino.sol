// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {RollupPassage} from "zenith/src/passage/RollupPassage.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title PecorinoConstants
/// @author init4
/// @notice Constants for the Pecorino testnet.
/// @dev These constants are used to configure the SignetStd contract in its
///      constructor, if the chain ID matches the Pecorino testnet chain ID.
library PecorinoConstants {
    /// @notice The Pecorino host chain ID.
    uint32 constant HOST_CHAIN_ID = 3151908;
    /// @notice The Pecorino Rollup chain ID.
    uint32 constant ROLLUP_CHAIN_ID = 14174;

    /// @notice The Rollup Passage contract for the Pecorino testnet.
    RollupPassage constant PECORINO_ROLLUP_PASSAGE = RollupPassage(payable(0x0000000000007369676E65742D70617373616765));

    /// @notice The Rollup Orders contract for the Pecorino testnet.
    RollupOrders constant PECORINO_ROLLUP_ORDERS = RollupOrders(0x000000000000007369676E65742D6f7264657273);

    /// USDC token for the Pecorino testnet host chain.
    address constant HOST_USDC = 0x65Fb255585458De1F9A246b476aa8d5C5516F6fd;
    /// USDT token for the Pecorino testnet host chain.
    address constant HOST_USDT = 0xb9Df1b911B6cf6935b2a918Ba03dF2372E94e267;
    /// WBTC token for the Pecorino testnet host chain.
    address constant HOST_WBTC = 0xfb29F7d7a4CE607D6038d44150315e5F69BEa08A;
    /// WETH token for the Pecorino testnet host chain.
    address constant HOST_WETH = 0xd03d085B78067A18155d3B29D64914df3D19A53C;

    /// @notice WETH token address for the Pecorino testnet.
    IERC20 constant WETH = IERC20(0x0000000000000000007369676e65742d77657468);
    /// @notice WBTC token address for the Pecorino testnet.
    IERC20 constant WBTC = IERC20(0x0000000000000000007369676e65742D77627463);
    /// @notice WUSD token address for the Pecorino testnet.
    IERC20 constant WUSD = IERC20(0x0000000000000000007369676e65742D77757364);
}

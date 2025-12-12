// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {RollupPassage} from "zenith/src/passage/RollupPassage.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract RollupConstants {
    /// @notice The Rollup Passage contract for the Parmigiana testnet.
    RollupPassage constant PASSAGE = RollupPassage(payable(0x0000000000007369676E65742D70617373616765));

    /// @notice The Rollup Orders contract for the Parmigiana testnet.
    RollupOrders constant ORDERS = RollupOrders(0x000000000000007369676E65742D6f7264657273);

    /// @notice WETH token address for the Parmigiana testnet.
    IERC20 constant WETH = IERC20(0x0000000000000000007369676e65742d77657468);
    /// @notice WBTC token address for the Parmigiana testnet.
    IERC20 constant WBTC = IERC20(0x0000000000000000007369676e65742D77627463);
    /// @notice WUSD token address for the Parmigiana testnet.
    IERC20 constant WUSD = IERC20(0x0000000000000000007369676e65742D77757364);
}

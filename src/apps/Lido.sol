// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {BridgeL2} from "./Bridge.sol";

/// @notice An example contract, implementing LIDO staking from Signet L2, with
/// support for CCIP teleporting.
/// Allows bridging two ways:
/// - Signet native bridging with Orders.
/// - CCIP Teleporting via support for the CCT standard.
///
/// Bridging with Signet:
/// - bridgeIn: Creates an order that delilvers wstETH to `HOST_PASSAGE` on L1.
///   If the order is filled, mints stETH on L2 to `recipient`.
/// - bridgeOut: Burns stETH on L2 from `msg.sender`, and creates an order
///   that delivers wstETH to `recipient` on L1.
/// - enter: Transfers WETH from `funder`, creates an order that converts
///   WETH to wstETH on L1 and delivers it to `HOST_PASSAGE`, and mints stETH
///   on L2 to `recipient`.
///
contract LidoL2 is BridgeL2 {
    using SafeERC20 for IERC20;

    /// @notice The WstETH token on the host.
    address public immutable HOST_WSTETH;

    constructor(address _hostWsteth) BridgeL2(_hostWsteth, HOST_PASSAGE, "Lido Staked Ether", "stETH", 18) {
        HOST_WSTETH = _hostWsteth;
        WETH.forceApprove(address(ORDERS), type(uint256).max);
    }

    /// @notice Transfer WETH from `funder`, create an order to convert it to
    /// wstETH on L1 and bridge it to L2, and mint stETH to `recipient`.
    function enter(address funder, uint256 amountIn, address recipient, uint256 amountOut) external {
        WETH.safeTransferFrom(funder, address(this), amountIn);

        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeWethInput(amountIn);

        _bridgeIn(recipient, amountOut, inputs);
    }
}

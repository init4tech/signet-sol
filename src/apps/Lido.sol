// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {SignetL2} from "../l2/Signet.sol";
import {BurnMintERC20} from "../vendor/BurnMintERC20.sol";

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
contract LidoL2 is SignetL2, BurnMintERC20 {
    using SafeERC20 for IERC20;

/// @notice The WstETH token on the host.
    address public immutable HOST_WSTETH;

    constructor(address _hostWsteth) BurnMintERC20("Signet Lido Staked Ether", "stETH", 18, 0, 0) {
        HOST_WSTETH = _hostWsteth;
        WETH.forceApprove(address(ORDERS), type(uint256).max);
    }

    /// @notice Create an order to bridge in wstETH from L1, and mint stETH on
    /// L2.
    function _bridgeIn(address recipient, uint256 amount, RollupOrders.Input[] memory inputs) internal {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_WSTETH, amount, address(HOST_PASSAGE));

        ORDERS.initiate(block.timestamp, inputs, outputs);

        _mint(recipient, amount);
    }

    /// @notice Bridge in wstETH from L1, and mint stETH on L2.
    function bridgeIn(address recipient, uint256 amount) external {
        _bridgeIn(recipient, amount, new RollupOrders.Input[](0));
    }

    /// @notice Burn stETH on L2, and create an order to bridge out wstETH to
    /// L1. If the order is not filled, the stETH will not be burned.
    ///
    /// This transaction should be paired with some off-chain logic that fills
    /// orders from the L1 bank.
    function bridgeOut(address recipient, uint256 amount) public {
        _burn(msg.sender, amount);

        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_WSTETH, amount, recipient);

        ORDERS.initiate(block.timestamp, new RollupOrders.Input[](0), outputs);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SignetStd} from "../SignetStd.sol";

/// @notice This contract provides a modifier that allows functions to be gated
///         by requiring a payment of a specified amount of native asset.
abstract contract PayMe is SignetStd {
    /// @notice This modifier crates an order with no input, that pays the
    ///         specified amount of native asset to the contract. It can be used
    ///         to gate access to payment-gate functions.
    modifier payMe(uint256 amount) {
        _;
        demandPayment(NATIVE_ASSET, amount);
    }

    /// @notice A version of payMe that subsidizes the gas cost of the
    /// transaction by deducting it from the payment amount.
    modifier payMeSubsidizedGas(uint256 amount) {
        uint256 pre = gasleft();
        uint256 gp = tx.gasprice;
        _;
        uint256 post = gasleft();
        uint256 loot = amount - (gp * (pre - post));
        demandPayment(NATIVE_ASSET, loot);
    }

    /// @notice Creates an order that demands payment of the specified amount
    ///         of the specified asset to the contract.
    /// @dev This is useful for cases where the payment should go to the
    ///      contract itself, such as for fees or service charges.
    /// @param asset The address of the asset to be paid.
    /// @param amount The amount of the asset to be paid.
    function demandPayment(address asset, uint256 amount) internal {
        demandPaymentTo(asset, amount, address(this));
    }

    /// @notice Creates an order that demands payment of the specified amount
    ///         of the specified asset to a specific recipient.
    /// @dev This is useful for cases where the payment should go to a different
    ///      address, such as a treasury or a specific user.
    /// @param asset The address of the asset to be paid.
    /// @param amount The amount of the asset to be paid.
    /// @param recipient The address that will receive the payment.
    function demandPaymentTo(address asset, uint256 amount, address recipient) internal {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeRollupOutput(asset, amount, recipient);

        ORDERS.initiate(
            block.timestamp, // this is equivalent to no deadline
            new RollupOrders.Input[](0), // no inputs
            outputs
        );
    }
}

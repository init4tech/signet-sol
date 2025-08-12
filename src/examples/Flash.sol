// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SignetStd} from "../SignetStd.sol";

/// @notice This contract provides a modifier that allows functions to
///         utilize liquidity only during the duration of a function.
abstract contract Flash is SignetStd {
    /// @notice This modifier enables a contract to access some amount only
    ///         during function execution - the amount is received by the
    ///         contract before the function executes, then is sent directly
    ///         back at the end.
    ///
    ///         This way, the function can utilize the liquidity during
    ///         transaction execution.
    /// @param asset The address of the asset to be flash held.
    /// @param amount The amount of the asset to be flash held.
    modifier flash(address asset, uint256 amount) {
        _;

        // Output is received *before* the modified function is called
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeRollupOutput(asset, amount, address(this));

        // Input is sent back after the modified function
        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeInput(asset, amount);

        ORDERS.initiate(
            block.timestamp, // this is equivalent to no deadline
            inputs,
            outputs
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SignetL2} from "../Signet.sol";

/// @notice This contract provides tools for contracts to pay searchers to run
///         code.
abstract contract PayYou is SignetL2 {
    /// @notice A modifier that creates USD MEV of the specified amount.
    modifier paysYou(uint256 tip) {
        _;
        providePayment(NATIVE_ASSET, tip);
    }

    /// @notice A version of paysYou that also subsidizes the gas cost of the
    ///         function modified.
    modifier paysYourGas(uint256 tip) {
        uint256 pre = gasleft();
        _;
        _paysYourGasAfter(pre, tip);
    }

    /// @notice This silences spurious foundry warnings.
    function _paysYourGasAfter(uint256 pre, uint256 tip) internal {
        uint256 gp = tx.gasprice;
        uint256 post = gasleft();
        uint256 loot = tip + (gp * (pre - post));
        providePayment(NATIVE_ASSET, loot);
    }

    /// @notice Create MEV of the specified asset and amount.
    /// @param asset The address of the asset to be paid.
    /// @param amount The amount of the asset to be paid.
    function providePayment(address asset, uint256 amount) internal {
        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeInput(asset, amount);

        ORDERS.initiate{value: amount}(
            block.timestamp, // no deadline
            inputs,
            new RollupOrders.Output[](0) // no outputs
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMorpho, MarketParams} from "../interfaces/IMorpho.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SignetStd} from "../SignetStd.sol";
import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";

// How this works:
// - The Signet Orders system calls `transferFrom` and check for the presence
//   of a `Fill` event.
// - The MorphoShortcut contract implements `transferFrom` to run
//   supply/repay logic on a specific Morpho Market.
// - The rollup contract uses Orders to send tokens to the shortcut
//   and then call the shortcut to perform the action.
// - This all occurs in the same block.

// The rollup order is structured as follows:
// - Input: X token on rollup chain.
// - Output: transfer X token on host chain to shortcut.
// - Output: invoke host chain shortcut contract.
//
// The Signet STF logic ensures that the Input is not delivered unless the
// outputs are succesful.

// Note:
// We've provided a rollup contract for the example, but this could also be
// initiated via a signed order from an EOA. No contract is needed. Both
// contracts and EOAs can use the Morpho shortcut to interact with Morpho from
// Signet.

// Note:
// The example order has no spread. Real orders can have a spread, and can also
// have their inputs in ANY asset. I.e. the user can use rollup ETH to pay for
// USDC collateral or repay a WBTC loan on the host Morpho market. This is
// pretty neat.

// The Rollup contract creates orders to interact with Morpho on host net via
// the shortcut.
contract UseMorpho is SignetStd {
    /// @dev Address of the shortcut on the host chain.
    address immutable repayShortcut;
    address immutable supplyShortcut;

    address immutable hostLoanToken;
    address immutable hostCollateralToken;

    IERC20 immutable loanToken;
    IERC20 immutable collateralToken;

    constructor(address _shortcut, address _hostLoan, address _hostCollateral) SignetStd() {
        // The address of the shortcut contract should be well-known.
        shortcut = _shortcut;

        // Autodetect rollup tokens based on token addresses on host network.
        hostLoanToken = _hostLoan;
        hostCollateralToken = _hostCollateral;
        if (_hostLoan == HOST_WETH) {
            loanToken = WETH;
        } else if (_hostLoan == HOST_WBTC) {
            loanToken = WBTC;
        } else if (_hostLoan == HOST_USDC || _hostLoan == HOST_USDT) {
            loanToken = WUSD;
        } else {
            revert("Unsupported loan token");
        }

        // Pre-emptively approve the Orders contract to spend our tokens.
        loanToken.approve(address(ORDERS), type(uint256).max);
        collateralToken.approve(address(ORDERS), type(uint256).max);
    }

    function supply(address onBehalf, uint256 amount) external {
        if (amount > 0) {
            collateralToken.transferFrom(msg.sender, address(this), amount);
        }

        // the amount is whatever our current balance is
        amount = collateralToken.balanceOf(address(this));

        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeInput(address(collateralToken), amount);

        // The first output pays the collateral token to the shortcut.
        // The second output calls the shortcut to supply the collateral.
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](2);
        outputs[0] = makeHostOutput(address(hostCollateralToken), amount, supplyShortcut);
        outputs[1] = makeHostOutput(supplyShortcut, amount, onBehalf);

        ORDERS.initiate(
            block.timestamp, // no deadline
            inputs,
            outputs
        );
    }

    function repay(address onBehalf, uint256 amount) external {
        if (amount > 0) {
            loanToken.transferFrom(msg.sender, address(this), amount);
        }

        // Send all tokens.
        amount = loanToken.balanceOf(address(this));

        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeInput(address(loanToken), amount);

        // The first output pays the loan token to the shortcut.
        // The second output calls the shortcut to repay the loan.
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](2);
        outputs[0] = makeHostOutput(address(hostLoanToken), amount, repayShortcut);
        outputs[1] = makeHostOutput(repayShortcut, amount, onBehalf);

        ORDERS.initiate(
            block.timestamp, // no deadline
            inputs,
            outputs
        );
    }
}

abstract contract HostMorphoUser {
    IMorpho immutable morpho;

    // This is an unrolled MarketParams struct.
    IERC20 immutable loanToken;
    IERC20 immutable collateralToken;

    address immutable oracle;
    address immutable irm;
    uint256 immutable lltv;

    error InsufficentTokensReceived(uint256 received, uint256 required);

    constructor(IMorpho _morpho, MarketParams memory _params) {
        morpho = _morpho;

        loanToken = IERC20(_params.loanToken);
        collateralToken = IERC20(_params.collateralToken);
        oracle = _params.oracle;
        irm = _params.irm;
        lltv = _params.lltv;

        loanToken.approve(address(_morpho), type(uint256).max);
        collateralToken.approve(address(_morpho), type(uint256).max);
    }

    function checkReceived(uint256 received, uint256 required) internal pure {
        if (received < required) {
            revert InsufficentTokensReceived(received, required);
        }
    }

    function loadParams() internal view returns (MarketParams memory params) {
        params.loanToken = address(loanToken);
        params.collateralToken = address(collateralToken);
        params.oracle = oracle;
        params.irm = irm;
        params.lltv = lltv;
    }
}

// This contract should be deployed on the host chain. It is used as a shortcut
// to supply collateral to Morpho and can be invoked by the rollup via an Order.
contract HostMorphoRepay is HostMorphoUser {
    constructor(IMorpho _morpho, MarketParams memory _params) HostMorphoUser(_morpho, _params) {}

    /// Uses the ERC20 transferFrom interface to invoke contract logic. This
    /// allows us to invoke logic from the Orders contract
    function transferFrom(address, address recipient, uint256 amount) external returns (bool) {
        uint256 loanTokenBalance = loanToken.balanceOf(address(this));
        checkReceived(loanTokenBalance, amount);
        morpho.repay(loadParams(), loanTokenBalance, 0, recipient, "");
        return true;
    }
}

contract HostMorphoSupply is HostMorphoUser {
    constructor(IMorpho _morpho, MarketParams memory _params) HostMorphoUser(_morpho, _params) {}

    /// Uses the ERC20 transferFrom interface to invoke contract logic. This
    /// allows us to invoke logic from the Orders contract
    function transferFrom(address, address recipient, uint256 amount) external returns (bool) {
        uint256 collateralTokenBalance = collateralToken.balanceOf(address(this));

        checkReceived(collateralTokenBalance, amount);

        morpho.supplyCollateral(loadParams(), collateralTokenBalance, recipient, "");

        // Future extension:
        // borrow some amount of loanToken
        // and send it to the rollup

        return true;
    }
}

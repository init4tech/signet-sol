// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMorpho, MarketParams} from "../interfaces/IMorpho.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SignetStd} from "../SignetStd.sol";
import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";

// Rollup contract that uses a host chain Morpho shortcut to supply collateral
// and repay loans on behalf of the rollup user.
contract UseMorpho is SignetStd {
    address immutable shortcut;

    address immutable hostLoanToken;
    address immutable hostCollateralToken;

    IERC20 immutable loanToken;
    IERC20 immutable collateralToken;

    constructor(address _shortcut, address _hostLoan, address _hostCollateral) SignetStd() {
        shortcut = _shortcut;
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

        loanToken.approve(address(ORDERS), type(uint256).max);
        collateralToken.approve(address(ORDERS), type(uint256).max);
    }

    function supply(uint256 amount) external {
        if (amount > 0) {
            collateralToken.transferFrom(msg.sender, address(this), amount);
        }

        // the amount is whatever our current balance is
        amount = collateralToken.balanceOf(address(this));

        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeInput(address(collateralToken), amount);

        // The output pays the collateral token to the shortcut,
        // Then calls the shortcut to supply the collateral.
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](2);
        outputs[0] = makeHostOutput(address(hostCollateralToken), amount, shortcut);
        // call shortcut
        outputs[1] = makeHostOutput(shortcut, 0, address(this));

        ORDERS.initiate(
            block.timestamp, // no deadline
            inputs,
            outputs
        );
    }

    function repay(uint256 amount) external {
        if (amount > 0) {
            loanToken.transferFrom(msg.sender, address(this), amount);
        }

        // the amount is whatever our current balance is
        amount = loanToken.balanceOf(address(this));

        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeInput(address(loanToken), amount);

        // The output pays the loan token to the shortcut,
        // Then calls the shortcut to repay the loan.
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](2);
        outputs[0] = makeHostOutput(address(hostLoanToken), amount, shortcut);
        outputs[1] = makeHostOutput(shortcut, 0, address(this)); // call shortcut

        ORDERS.initiate(
            block.timestamp, // no deadline
            inputs,
            outputs
        );
    }
}

// This contract should be deployed on the host chain. It is used as a shortcut
// to supply collateral to Morpho and can be invoked by the rollup via an Order.
contract HostMorphoShortcut {
    IMorpho immutable morpho;

    // This is an unrolled MarketParams struct.
    IERC20 immutable loanToken;
    IERC20 immutable collateralToken;
    address immutable oracle;
    address immutable irm;
    uint256 immutable lltv;

    address immutable onBehalf;

    constructor(IMorpho _morpho, MarketParams memory _params, address _onBehalf) {
        morpho = _morpho;

        loanToken = IERC20(_params.loanToken);
        collateralToken = IERC20(_params.collateralToken);
        oracle = _params.oracle;
        irm = _params.irm;
        lltv = _params.lltv;

        onBehalf = _onBehalf;

        collateralToken.approve(address(_morpho), type(uint256).max);
    }

    fallback() external {
        MarketParams memory params;
        params.loanToken = address(loanToken);
        params.collateralToken = address(collateralToken);
        params.oracle = oracle;
        params.irm = irm;
        params.lltv = lltv;

        uint256 loanTokenBalance = loanToken.balanceOf(address(this));
        uint256 collateralTokenBalance = collateralToken.balanceOf(address(this));

        // If we have loan tokens, we are repaying a loan.
        if (loanTokenBalance > 0) {
            morpho.repay(params, loanTokenBalance, 0, onBehalf, "");
            return;
        }

        // If we have collateral tokens, we are supplying collateral.
        if (collateralTokenBalance > 0) {
            morpho.supplyCollateral(params, collateralTokenBalance, onBehalf, "");

            // borrow and send to rollup?

            return;
        }

        revert("No tokens received");
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {SignetL2} from "../../l2/Signet.sol";
import {BurnMintERC20} from "../../vendor/BurnMintERC20.sol";

contract LidoL2 is SignetL2, BurnMintERC20 {
    using SafeERC20 for IERC20;

    address public immutable HOST_WSTETH;

    constructor(address _hostWsteth) BurnMintERC20("Signet Lido Staked Ether", "stETH", 18, 0, 0) {
        HOST_WSTETH = _hostWsteth;
        WETH.forceApprove(address(ORDERS), type(uint256).max);
    }

    function _bridgeIn(address recipient, uint256 amount, RollupOrders.Input[] memory inputs) internal {
        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_WSTETH, amount, address(HOST_PASSAGE));

        ORDERS.initiate(block.timestamp, inputs, outputs);

        _mint(recipient, amount);
    }

    function bridgeIn(address recipient, uint256 amount) external {
        _bridgeIn(recipient, amount, new RollupOrders.Input[](0));
    }

    function bridgeOut(address recipient, uint256 amount) public {
        _burn(msg.sender, amount);

        RollupOrders.Output[] memory outputs = new RollupOrders.Output[](1);
        outputs[0] = makeHostOutput(HOST_WSTETH, amount, recipient);

        ORDERS.initiate(block.timestamp, new RollupOrders.Input[](0), outputs);
    }

    function enter(address funder, uint256 amountIn, address recipient, uint256 amountOut) external {
        WETH.safeTransferFrom(funder, address(this), amountIn);

        RollupOrders.Input[] memory inputs = new RollupOrders.Input[](1);
        inputs[0] = makeWethInput(amountIn);

        _bridgeIn(recipient, amountOut, inputs);
    }
}

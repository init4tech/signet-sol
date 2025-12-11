// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >0.8.13;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    /// @notice Deposit ETH to get WETH
    function deposit() external payable;

    /// @notice Withdraw WETH to get ETH
    function withdraw(uint256 amount) external;
}

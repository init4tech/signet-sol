// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RollupOrders} from "zenith/src/orders/RollupOrders.sol";
import {RollupPassage} from "zenith/src/passage/RollupPassage.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {ParmigianaConstants} from "../chains/Parmigiana.sol";
import {AddressAliasHelper} from "../vendor/AddressAliasHelper.sol";

contract SignetL2 {
    /// @notice Sentinal value for the native asset in order inputs/outputs
    address constant NATIVE_ASSET = address(0);

    /// @notice System address that produces System minted tokens.
    address constant TOKEN_MINTER = 0x00000000000000000000746f6b656E61646d696E;

    /// @notice The chain ID of the host network.
    uint32 internal immutable HOST_CHAIN_ID;

    /// @notice The Rollup Passage contract.
    RollupPassage internal immutable PASSAGE;
    /// @notice The Rollup Orders contract.
    RollupOrders internal immutable ORDERS;

    /// @notice The address of the Rollup Passage on the host network.
    address immutable HOST_PASSAGE;

    /// @notice The WETH token address.
    IERC20 internal immutable WETH;
    /// @notice The WBTC token address.
    IERC20 internal immutable WBTC;
    /// @notice The WUSD token address.
    IERC20 internal immutable WUSD;

    /// @notice The USDC token address on the host network.
    address internal immutable HOST_USDC;
    /// @notice The USDT token address on the host network.
    address internal immutable HOST_USDT;
    /// @notice The WBTC token address on the host network.
    address internal immutable HOST_WBTC;
    /// @notice The WETH token address on the host network.
    address internal immutable HOST_WETH;

    /// @notice Error for unsupported chain IDs.
    error UnsupportedChain(uint256);

    constructor() {
        // Auto-configure based on the chain ID.
        if (block.chainid == ParmigianaConstants.ROLLUP_CHAIN_ID) {
            HOST_CHAIN_ID = ParmigianaConstants.HOST_CHAIN_ID;

            HOST_PASSAGE = address(ParmigianaConstants.HOST_PASSAGE);

            PASSAGE = ParmigianaConstants.ROLLUP_PASSAGE;
            ORDERS = ParmigianaConstants.ROLLUP_ORDERS;

            WETH = ParmigianaConstants.WETH;
            WBTC = ParmigianaConstants.WBTC;
            WUSD = ParmigianaConstants.WUSD;

            HOST_USDC = ParmigianaConstants.HOST_USDC;
            HOST_USDT = ParmigianaConstants.HOST_USDT;
            HOST_WBTC = ParmigianaConstants.HOST_WBTC;
            HOST_WETH = ParmigianaConstants.HOST_WETH;
        } else {
            revert UnsupportedChain(block.chainid);
        }
    }

    /// @notice Gets the aliased address of this contracat, representing itself
    /// on L1. Use with caustion.
    function aliasedSelf() internal view returns (address) {
        return AddressAliasHelper.applyL1ToL2Alias(address(this));
    }

    /// @notice Creates an Input struct for the RollupOrders.
    /// @param token The address of the token.
    /// @param amount The amount of the token.
    /// @return input The created Input struct.
    function makeInput(address token, uint256 amount) internal pure returns (RollupOrders.Input memory input) {
        input.token = token;
        input.amount = amount;
    }

    /// @notice Creates an Input struct for the native asset (USD).
    /// @param amount The amount of the native asset (in wei).
    /// @return input The created Input struct for the native asset.
    function makeUsdInput(uint256 amount) internal pure returns (RollupOrders.Input memory input) {
        input.token = address(0);
        input.amount = amount;
    }

    function makeWethInput(uint256 amount) internal view returns (RollupOrders.Input memory input) {
        input.token = address(WETH);
        input.amount = amount;
    }

    function makeWbtcInput(uint256 amount) internal view returns (RollupOrders.Input memory input) {
        input.token = address(WBTC);
        input.amount = amount;
    }

    /// @notice Creates an Output struct for the RollupOrders.
    /// @param token The address of the token.
    /// @param amount The amount of the token.
    /// @param recipient The address to receive the output tokens.
    /// @param chainId The chain ID for the output.
    /// @return output The created Output struct.
    function makeOutput(address token, uint256 amount, address recipient, uint32 chainId)
        private
        pure
        returns (RollupOrders.Output memory output)
    {
        output.token = token;
        output.amount = amount;
        output.recipient = recipient;
        output.chainId = chainId;
    }

    /// @notice Creates an Output struct for the host network.
    /// @param token The address of the token.
    /// @param amount The amount of the token.
    /// @param recipient The address to receive the output tokens.
    /// @return output The created Output struct for the host network.
    function makeHostOutput(address token, uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeOutput(token, amount, recipient, HOST_CHAIN_ID);
    }

    /// @notice Creates an Output struct for the rollup network.
    /// @param token The address of the token.
    /// @param amount The amount of the token.
    /// @param recipient The address to receive the output tokens.
    /// @return output The created Output struct for the rollup network.
    function makeRollupOutput(address token, uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeOutput(token, amount, recipient, uint32(block.chainid));
    }

    /// @notice Creates an Output struct for the host USDC token.
    /// @param amount The amount of USDC to receive.
    /// @param recipient The address to receive the USDC tokens.
    /// @return output The created Output struct for the host USDC token.
    function hostUsdcOutput(uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeHostOutput(HOST_USDC, amount, recipient);
    }

    /// @notice Creates an Output struct for the host USDT token.
    /// @param amount The amount of USDT to receive.
    /// @param recipient The address to receive the USDT tokens.
    /// @return output The created Output struct for the host USDT token.
    function hostUsdtOutput(uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeHostOutput(HOST_USDT, amount, recipient);
    }

    /// @notice Creates an Output struct for the host WBTC token.
    /// @param amount The amount of WBTC to receive.
    /// @param recipient The address to receive the WBTC tokens.
    /// @return output The created Output struct for the host WBTC token.
    function hostWbtcOutput(uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeHostOutput(HOST_WBTC, amount, recipient);
    }

    /// @notice Creates an Output struct for the host WETH token.
    /// @param amount The amount of WETH to receive.
    /// @param recipient The address to receive the WETH tokens.
    /// @return output The created Output struct for the host WETH token.
    function hostWethOutput(uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeHostOutput(HOST_WETH, amount, recipient);
    }

    /// @notice Creates an Output struct for the host native asset (ETH).
    /// @param amount The amount of native asset to receive.
    /// @param recipient The address to receive the native asset.
    /// @return output The created Output struct for the host native asset.
    function hostEthOutput(uint256 amount, address recipient)
        internal
        view
        returns (RollupOrders.Output memory output)
    {
        return makeHostOutput(address(0), amount, recipient);
    }
}

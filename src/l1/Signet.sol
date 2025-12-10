// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HostOrders} from "zenith/src/orders/HostOrders.sol";
import {Passage} from "zenith/src/passage/Passage.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IWETH} from "../interfaces/IWETH.sol";

import {ParmigianaConstants} from "../chains/Parmigiana.sol";
import {AddressAliasHelper} from "../vendor/AddressAliasHelper.sol";

abstract contract SignetL1 {
    using SafeERC20 for IERC20;

    /// @notice Sentinel value for the native asset in order inputs/outputs
    address constant NATIVE_ASSET = address(0);

    /// @notice The chain ID of the host network.
    uint256 immutable HOST_CHAIN_ID;

    /// @notice The Passage address
    Passage internal immutable PASSAGE;
    /// @notice The Host Orders address
    HostOrders internal immutable ORDERS;

    /// @notice The WETH token address.
    IWETH internal immutable WETH;
    /// @notice The WBTC token address.
    IERC20 internal immutable WBTC;
    /// @notice The USDC token address.
    IERC20 internal immutable USDC;
    /// @notice The USDT token address.
    IERC20 internal immutable USDT;

    /// @notice The Rollup WUSD token address.
    address internal immutable RU_WUSD;
    /// @notice The Rollup WBTC token address.
    address internal immutable RU_WBTC;
    /// @notice The Rollup WETH token address.
    address internal immutable RU_WETH;

    /// @notice Error for unsupported chain IDs.
    error UnsupportedChain(uint256);

    constructor() {
        uint256 chainId = block.chainid;
        if (chainId == ParmigianaConstants.HOST_CHAIN_ID) {
            HOST_CHAIN_ID = ParmigianaConstants.HOST_CHAIN_ID;

            PASSAGE = ParmigianaConstants.HOST_PASSAGE;
            ORDERS = ParmigianaConstants.HOST_ORDERS;

            WETH = IWETH(ParmigianaConstants.HOST_WETH);
            WBTC = IERC20(ParmigianaConstants.HOST_WBTC);
            USDC = IERC20(ParmigianaConstants.HOST_USDC);
            USDT = IERC20(ParmigianaConstants.HOST_USDT);
        } else {
            revert UnsupportedChain(block.chainid);
        }
    }

    /// @notice Returns the address of this contract on L2, applying an
    /// address alias.
    function selfOnL2() internal view virtual returns (address) {
        address self = address(this);
        if (self.code.length == 23) {
            bool is7702;

            assembly {
                let ptr := mload(0x40)
                extcodecopy(self, ptr, 0, 0x20)
                is7702 := eq(shr(232, mload(ptr)), 0xEF0100)
                // clean the memory we used. Unnecessary, but good hygiene
                mstore(ptr, 0x0)
            }
            if (is7702) {
                return address(this);
            }
        }
        return AddressAliasHelper.applyL1ToL2Alias(address(this));
    }

    /// @notice Helper to create an output struct.
    function makeOutput(address token, uint256 amount, address recipient)
        internal
        view
        returns (HostOrders.Output memory output)
    {
        output.token = token;
        output.amount = amount;
        output.recipient = recipient;
        // forge-lint: disable-next-line(unsafe-typecast)
        output.chainId = uint32(HOST_CHAIN_ID);
    }

    /// @notice Helper to create an Output struct for usdc.
    function usdcOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(USDC), amount, recipient);
    }

    /// @notice Helper to create an Output struct for usdt.
    function usdtOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(USDT), amount, recipient);
    }

    /// @notice Helper to create an Output struct for wbtc.
    function wbtcOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(WBTC), amount, recipient);
    }

    /// @notice Helper to create an Output struct for weth.
    function wethOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(WETH), amount, recipient);
    }

    /// @notice Helper to create an Output struct for eth.
    function ethOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(NATIVE_ASSET, amount, recipient);
    }

    /// @notice Send tokens into Signet via the Passage contract.
    function tokensToSignet(address token, uint256 amount) internal {
        if (token == NATIVE_ASSET) {
            ethToSignet(amount);
            return;
        }
        IERC20(token).forceApprove(address(PASSAGE), amount);
        PASSAGE.enterToken(selfOnL2(), token, amount);
    }

    /// @notice Send ETH into Signet via the Passage contract.
    function ethToSignet(uint256 amount) internal {
        PASSAGE.enter{value: amount}(selfOnL2());
    }

    /// @notice Send WETH into Signet via the Passage contract.
    function wethToSignet(uint256 amount) internal {
        WETH.withdraw(amount);
        ethToSignet(amount);
    }
}

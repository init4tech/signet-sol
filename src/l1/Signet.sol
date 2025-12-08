// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HostOrders} from "zenith/src/orders/HostOrders.sol";
import {Passage} from "zenith/src/passage/Passage.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {AddressAliasHelper} from "../vendor/AddressAliasHelper.sol";
import {PecorinoConstants} from "../chains/Pecorino.sol";

abstract contract SignetL1 {
    /// @notice Sentinal value for the native asset in order inputs/outputs
    address constant NATIVE_ASSET = address(0);

    /// @notice The Passage address
    Passage internal immutable PASSAGE;
    /// @notice The Host Orders address
    HostOrders internal immutable ORDERS;

    /// @notice The WETH token address.
    IERC20 internal immutable WETH;
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
        if (block.chainid == PecorinoConstants.HOST_CHAIN_ID) {
            PASSAGE = PecorinoConstants.HOST_PASSAGE;
            ORDERS = PecorinoConstants.HOST_ORDERS;

            WETH = IERC20(PecorinoConstants.HOST_WETH);
            WBTC = IERC20(PecorinoConstants.HOST_WBTC);
            USDC = IERC20(PecorinoConstants.HOST_USDC);
            USDT = IERC20(PecorinoConstants.HOST_USDT);

            RU_WUSD = address(PecorinoConstants.WUSD);
            RU_WBTC = address(PecorinoConstants.WBTC);
            RU_WETH = address(PecorinoConstants.WETH);
        } else {
            revert UnsupportedChain(block.chainid);
        }
    }

    /// @notice Returns the address of this contract on L2, applying an
    /// address alias.
    function selfOnL2() internal view virtual returns (address) {
        if (address(this).code.length == 23) {
            bool is7702;
            assembly {
                let ptr := mload(0x40)
                extcodecopy(caller(), ptr, 0, 0x20)
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

    function makeOutput(address token, uint256 amount, address recipient)
        internal
        pure
        returns (HostOrders.Output memory output)
    {
        output.token = token;
        output.amount = amount;
        output.recipient = recipient;
        output.chainId = PecorinoConstants.HOST_CHAIN_ID;
    }

    function usdcOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(USDC), amount, recipient);
    }

    function usdtOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(USDT), amount, recipient);
    }

    function wbtcOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(WBTC), amount, recipient);
    }

    function wethOutput(uint256 amount, address recipient) internal view returns (HostOrders.Output memory output) {
        return makeOutput(address(WETH), amount, recipient);
    }

    function ethOutput(uint256 amount, address recipient) internal pure returns (HostOrders.Output memory output) {
        return makeOutput(NATIVE_ASSET, amount, recipient);
    }

    function enterSignetToken(address token, uint256 amount) internal {
        if (token == NATIVE_ASSET) {
            enterSignetEth(amount);
            return;
        }
        IERC20(token).approve(address(PASSAGE), amount);
        PASSAGE.enterToken(selfOnL2(), token, amount);
    }

    function enterSignetEth(uint256 amount) internal {
        PASSAGE.enter{value: amount}(selfOnL2());
    }
}

# Signet Solidity Examples

This repo contains solidity examples using the [Signet Orders] system to do
some fun and suprising things 🎀

Signet Orders are cross-chain, instant, atomic, and composable. Because Outputs
are effectively MEV, you can do some really interesting things with them. Like
[MevWallet], Signet Orders allow you to leverage MEV Searchers to:

- Move assets across chains
- Invoke functions on other chains
- Schedule transactions or function invocations
- Capture MEV produced by your application
- Impress your friends
- And more!

[MevWallet]: https://github.com/blunt-instruments/MevWallet
[Signet Orders]: https://signet.sh/docs/learn-about-signet/cross-chain-transfers/

## Main Examples

- [`SignetStd.sol`](./src/SignetStd.sol) - A simple contract that
  auto-configures Signet system parameters, based on the chain id.
- [`Flash.sol`](./src/examples/Flash.sol) - Allows your contract to flash borrow
  any asset (provided some searcher will provide it). Flash loans work by having an input and output of the same asset. The Output is then used as the Input to its own Order. This is pretty neat 🎀
- [`GetOut.sol`](./src/examples/GetOut.sol) - A shortcut contract for
  exiting Signet (by offering searchers a 50 bps fee).
- [`PayMe.sol`](./src/examples/PayMe.sol) - Payment gating for smart contracts,
  using a Signet Order with no inputs. These ensures that contract execution is invalid unless SOMEONE has filled the Order. Unlike traditional payment gates that check `msg.value`, this does NOT require the calling contract to manage cash flow. Instead _any third party_ can fill the order. The calling contract can be blind to the payment. This greatly simplifies contract logic required
  to implement payment gates.
- [`PayYou.sol`](./src/examples/PayYou.sol) - The opposite of payment gating,
  this allows a contract to generate MEV by offering a Signet Order with no outputs. This payment becomes a bounty for calling the contract, and functions as an incentivized scheduling system.

## Basic Repo Instructions

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

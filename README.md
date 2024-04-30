## Babe

https://collective.flashbots.net/t/request-for-suapp-coprocessor-for-base/3277

- Rigil:

ChatGPTSubnet: [0x83FcD96ce7267375fd1e42C8A908f531318b5fED](https://explorer.rigil.suave.flashbots.net/address/0x83FcD96ce7267375fd1e42C8A908f531318b5fED)

Babe: 

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

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

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## How To

### Deploy SuaveCaller.sol

```shell
$ forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/SuaveCaller.sol:SuaveCaller
```
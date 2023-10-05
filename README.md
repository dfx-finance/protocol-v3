# DFX Protocol V3

A decentralized foreign exchange protocol optimized for stablecoins and any erc20 tokens.

[![Discord](https://img.shields.io/discord/786747729376051211.svg?color=768AD4&label=discord&logo=https%3A%2F%2Fdiscordapp.com%2Fassets%2F8c9701b98ad4372b58f13fd9f65f966e.svg)](http://discord.dfx.finance/)
[![Twitter Follow](https://img.shields.io/twitter/follow/DFXFinance.svg?label=DFXFinance&style=social)](https://twitter.com/DFXFinance)

## Overview

DFX v3 is an update from DFX protocol v2 with some additional features including more decentralization, support of any erc20 tokens and mathematical calculation accuracy.

There are two major parts to the protocol: **Assimilators** and **Curves**. Assimilators allow the AMM to handle pairs of different value while also retrieving reported oracle prices for respective currencies. Curves allow the custom parameterization of the bonding curve with dynamic fees, halting bounderies, etc.

### Assimilators

Assimilators are a key part of the protocol, it converts all amounts to a "numeraire" which is essentially a base value used for computations across the entire protocol. This is necessary as we are dealing with pairs of different values. **AssimilatorFactory** is responsible for deploying new AssimilatorV3.

Oracle price feeds are also piped in through the assimilator as they inform what numeraire amounts should be set. Since oracle price feeds report their values in USD, all assimilators attempt to convert token values to a numeraire amount based on USD.

### Curve Parameter Terminology

High level overview.

| Name      | Description                                                                                               |
| --------- | --------------------------------------------------------------------------------------------------------- |
| Weights   | Weighting of the pair (only 50/50)                                                                        |
| Alpha     | The maximum and minimum allocation for each reserve                                                       |
| Beta      | Liquidity depth of the exchange; The higher the value, the flatter the curve at the reported oracle price |
| Delta/Max | Slippage when exchange is not at the reported oracle price                                                |
| Epsilon   | Fixed fee                                                                                                 |
| Lambda    | Dynamic fee captured when slippage occurs                                                                 |

In order to prevent anti-slippage being greater than slippate, DFX V3 requires deployers to set Lambda to 1(1e18).

For a more in-depth discussion, refer to [section 3 of the shellprotocol whitepaper](https://github.com/cowri/shell-solidity-v1/blob/master/Shell_White_Paper_v1.0.pdf)

### Major changes from the Shell Protocol

The main changes between V3 and the original code can be found in the following files:

- All the assimilators
- `AssimilatorV3.sol`
- `CurveFactoryV3.sol`
- `CurveMath.sol`
- `ProportionalLiquidity.sol`
- `Swaps.sol`
- `Structs.sol`

#### Different Valued Pairs

In the original implementation, all pools are assumed to be baskets of like-valued tokens. In our implementation, all pools are assumed to be pairs of different-valued FX stablecoins or any erc20 token pairs

This is achieved by having custom assimilators that normalize the foreign currencies to their USD counterparts. We're sourcing our FX price feed from chainlink oracles. See above for more information about assimilators.

Withdrawing and depositing related operations will respect the existing LP ratio. As long as the pool ratio hasn't changed since the deposit, amount in ~= amount out (minus fees), even if the reported price on the oracle changes. The oracle is only here to assist with efficient swaps.

#### Flashloans
Flashloans live in every curve contract produced by the CurveFactory. DFX curve flash function is based on the the flashloan model in UniswapV2. The user calling flash function must conform to the `IFlash.sol` interface. It must containing their own logic along with code to return the correct amount of tokens requested along with its respective fee. Flash function will check for the balances of the curve before and after to ensure that the correct amount of fees has been sent to the treasury as well as funds returned back to the curve. 

## Third Party Libraries

- [Openzeppelin contracts (v3.3.0)](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v3.3.0)
- [ABDKMath (v2.4)](https://github.com/abdk-consulting/abdk-libraries-solidity/releases/tag/v2.4)
- [Shell Protocol@48dac1c](https://github.com/cowri/shell-solidity-v1/tree/48dac1c1a18e2da292b0468577b9e6cbdb3786a4)


## Test Locally
1. Install Foundry

   - [Foundry Docs](https://jamesbachini.com/foundry-tutorial/)

2. Download all dependencies. 
    ```
    forge install
    ```
2. Run Ethereum mainnet forked testnet on your local in one terminal:

   ```
   anvil -f https://polygon-mainnet.g.alchemy.com/v2/${key} --fork-block-number 44073000
   ```

3. In another terminal, run 3 test script:

   ```
   forge test --match-contract V3Test -vvv -f http://127.0.0.1:8545
   ```
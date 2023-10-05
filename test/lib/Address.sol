// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library Mainnet {
    // Tokens
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant DFX = 0x888888435FDe8e7d4c54cAb67f206e4199454c60;
    address public constant CADC = 0xcaDC0acd4B445166f12d2C07EAc6E2544FbE2Eef;
    address public constant EUROC = 0x1aBaEA1f7C830bD89Acc67eC4af516284b1bC33c;
    address public constant XSGD = 0x70e8dE73cE538DA2bEEd35d14187F6959a8ecA96;
    address public constant NZDS = 0xDa446fAd08277B4D2591536F204E018f32B6831c;
    address public constant RAI = 0x03ab458634910AaD20eF5f1C8ee96F1D6ac54919;

    // Oracles
    // 8-decimals
    address public constant CHAINLINK_WETH_USD =
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant CHAINLINK_USDC_USD =
        0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
    address public constant CHAINLINK_USDT_USD =
        0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;
    address public constant CHAINLINK_DAI_USD =
        0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address public constant CHAINLINK_NZDS_USD =
        0x3977CFc9e4f29C184D4675f4EB8e0013236e5f3e;
    address public constant CHAINLINK_CAD_USD =
        0xa34317DB73e77d453b1B8d04550c44D10e981C8e;
    address public constant CHAINLINK_EUR_USD =
        0xb49f677943BC038e9857d61E7d053CaA2C1734C1;
    address public constant CHAINLINK_SGD_USD =
        0xe25277fF4bbF9081C75Ab0EB13B4A13a721f3E13;

    address public constant CHAINLINK_RAI_USD =
        0x3147D7203354Dc06D9fd350c7a2437bcA92387a4; // rai decimal is 18
    address public constant XSGD_USDC_POOL =
        0x2baB29a12a9527a179Da88F422cDaaA223A90bD5;
}

library Polygon {
    address public constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public constant EUROC = 0xE111178A87A3BFf0c8d18DECBa5798827539Ae99;
    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public constant LINK = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;

    address public constant CHAINLINK_USDC =
        0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7;
    address public constant CHAINLINK_EUROS =
        0x73366Fe0AA0Ded304479862808e02506FE556a98;
    address public constant CHAINLINK_WETH =
        0xF9680D99D6C9589e2a93a78A04A279e509205945;
    address public constant CHAINLINK_MATIC =
        0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
    address public constant CHAINLINK_LINK =
        0xd9FFdb71EbE7496cC440152d43986Aae0AB76665;

    address public constant CHAINLINK_MANA =
        0xA1CbF3Fe43BC3501e3Fc4b573e822c70e76A7512;

    address public constant CHAINLINK_BNB =
        0x82a6c4AF830caa6c97bb504425f6A66165C2c26e;
}

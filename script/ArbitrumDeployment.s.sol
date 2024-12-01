// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./curves/CurveParams.sol";

// Libraries
import "../src/Curve.sol";
import "../src/Config.sol";
import "../src/CurveVerifier.sol";

// Factories
import "../src/CurveFactoryV3.sol";

// Zap
import "../src/Zap.sol";
import "../src/Router.sol";
import "./Addresses.sol";

// Arbitrum DEPLOYMENT
contract ContractScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address OWNER = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // first deploy the config
        int128 protocolFee = 50_000;
        Config config = new Config(protocolFee, OWNER);

        // Deploy Assimilator
        AssimilatorFactory deployedAssimFactory = new AssimilatorFactory(address(config));

        // Deploy CurveVerifier
        CurveVerifier verifier = new CurveVerifier(address(config));

        // Deploy CurveFactoryV3
        CurveFactoryV3 deployedCurveFactory =
            new CurveFactoryV3(address(deployedAssimFactory), address(config), Arbitrum.WETH, address(verifier));

        // Attach CurveFactoryV3 to Assimilator
        deployedAssimFactory.setCurveFactory(address(deployedCurveFactory));

        // deploy usdc-cadc, cadc-crv, crv-dodo
        IOracle usdOracle = IOracle(Arbitrum.CHAINLINK_USDC_USD);
        IOracle cadOracle = IOracle(Arbitrum.CHAINLINK_CADC_USD);
        IOracle gyenOracle = IOracle(Arbitrum.CHAINLINK_GYEN_USD);

        // usdc-usdce curve info
        CurveInfo memory usdcUsdceCurveInfo = CurveInfo(
            "dfx-usdc-usdce-v3",
            "dfx-usdc-usdce-v3",
            Arbitrum.USDCe,
            Arbitrum.USDC,
            CurveParams.BASE_WEIGHT,
            CurveParams.QUOTE_WEIGHT,
            usdOracle,
            usdOracle,
            CurveParams.ALPHA,
            CurveParams.BETA,
            CurveParams.MAX,
            Arbitrum.USDCe_EPSILON,
            CurveParams.LAMBDA
        );

        // usdc-cadc curve info
        CurveInfo memory cadcUsdcCurveInfo = CurveInfo(
            "dfx-cadc-usdc-v3",
            "dfx-cadc-usdc-v3",
            Arbitrum.CADC,
            Arbitrum.USDC,
            CurveParams.BASE_WEIGHT,
            CurveParams.QUOTE_WEIGHT,
            cadOracle,
            usdOracle,
            CurveParams.ALPHA,
            CurveParams.BETA,
            CurveParams.MAX,
            Arbitrum.CADC_EPSILON,
            CurveParams.LAMBDA
        );

        // gyen-usdc curve info
        CurveInfo memory gyenUsdcCurveInfo = CurveInfo(
            "dfx-gyen-usdc-v3",
            "dfx-gyen-usdc-v3",
            Arbitrum.GYEN,
            Arbitrum.USDC,
            CurveParams.BASE_WEIGHT,
            CurveParams.QUOTE_WEIGHT,
            gyenOracle,
            usdOracle,
            CurveParams.ALPHA,
            CurveParams.BETA,
            CurveParams.MAX,
            Arbitrum.GYEN_EPSILON,
            CurveParams.LAMBDA
        );

        // Deploy all new Curves
        deployedCurveFactory.newCurve(usdcUsdceCurveInfo);
        deployedCurveFactory.newCurve(cadcUsdcCurveInfo);
        deployedCurveFactory.newCurve(gyenUsdcCurveInfo);
        Zap zap = new Zap(address(deployedCurveFactory));
        Router router = new Router(address(deployedCurveFactory));
        vm.stopBroadcast();

        console.log("Zap:", address(zap));
        console.log("Router:", address(router));
    }
}

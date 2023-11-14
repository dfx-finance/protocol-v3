// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./CurveParams.sol";

// Libraries
import "../src/Curve.sol";
import "../src/Config.sol";

// Factories
import "../src/CurveFactoryV3.sol";

// Zap
import "../src/Zap.sol";
import "../src/Router.sol";
import "./Addresses.sol";

// POLYGON DEPLOYMENT
contract ContractScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address OWNER = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        // first deploy the config
        int128 protocolFee = 50_000;
        Config config = new Config(protocolFee, OWNER);
        // Deploy Assimilator
        AssimilatorFactory deployedAssimFactory = new AssimilatorFactory(
            address(config)
        );
        // Deploy CurveFactoryV3
        CurveFactoryV3 deployedCurveFactory = new CurveFactoryV3(
            address(deployedAssimFactory),
            address(config),
            Polygon.WMATIC
        );
        // Attach CurveFactoryV3 to Assimilator
        deployedAssimFactory.setCurveFactory(address(deployedCurveFactory));
        IOracle usdOracle = IOracle(Polygon.CHAINLINK_USDC_USD);
        IOracle cadOracle = IOracle(Polygon.CHAINLINK_CAD_USD);
        IOracle sgdOracle = IOracle(Polygon.CHAINLINK_SGD_USD);
        IOracle trybOracle = IOracle(Polygon.CHAINLINK_TRY_USD);
        IOracle ngncOracle = IOracle(Polygon.CHAINLINK_NGNC_USD);
        CurveFactoryV3.CurveInfo memory usdcUsdceCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-usdc-usdce-v3",
                "dfx-usdc-usdce-v3",
                Polygon.USDCe,
                Polygon.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                usdOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Polygon.USDCe_EPSILON,
                CurveParams.LAMBDA
            );
        CurveFactoryV3.CurveInfo memory cadcUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-cadc-usdc-v3",
                "dfx-cadc-usdc-v3",
                Polygon.CADC,
                Polygon.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                cadOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Polygon.CADC_EPSILON,
                CurveParams.LAMBDA
            );
        CurveFactoryV3.CurveInfo memory xsgdUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-xsgd-usdc-v3",
                "dfx-xsgd-usdc-v3",
                Polygon.XSGD,
                Polygon.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                sgdOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Polygon.XSGD_EPSILON,
                CurveParams.LAMBDA
            );
        CurveFactoryV3.CurveInfo memory trybUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-tryb-usdc-v3",
                "dfx-tryb-usdc-v3",
                Polygon.TRYB,
                Polygon.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                trybOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Polygon.TRYB_EPSILON,
                CurveParams.LAMBDA
            );
        CurveFactoryV3.CurveInfo memory ngncUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-ngnc-usdc-v3",
                "dfx-ngnc-usdc-v3",
                Polygon.NGNC,
                Polygon.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                ngncOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Polygon.NGNC_EPSILON,
                CurveParams.LAMBDA
            );
        // Deploy all new Curves
        deployedCurveFactory.newCurve(usdcUsdceCurveInfo);
        deployedCurveFactory.newCurve(cadcUsdcCurveInfo);
        deployedCurveFactory.newCurve(xsgdUsdcCurveInfo);
        deployedCurveFactory.newCurve(trybUsdcCurveInfo);
        deployedCurveFactory.newCurve(ngncUsdcCurveInfo);
        Zap zap = new Zap(address(deployedCurveFactory));
        Router router = new Router(address(deployedCurveFactory));
        vm.stopBroadcast();
    }

    // function run() external {
    //     uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_1");
    //     vm.startBroadcast(deployerPrivateKey);
    //     Zap zap = new Zap(address(0x1dD11E6607D8C7aAab3d61ae1d8Da7B82aCa1ae9));
    //     vm.stopBroadcast();
    // }
}

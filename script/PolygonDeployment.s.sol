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
import "../src/interfaces/IERC20Detailed.sol";

// POLYGON DEPLOYMENT
contract ContractScript is Script {
    function run() external {
        address OWNER = 0x1246E96b7BC94107aa10a08C3CE3aEcc8E19217B;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
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

        // deploy usdc-cadc, cadc-wmatic, cadc-eurs, sgd-link

        IOracle usdOracle = IOracle(Polygon.CHAINLINK_USDC_USD);
        IOracle cadOracle = IOracle(Polygon.CHAINLINK_CAD_USD);
        IOracle eurOracle = IOracle(Polygon.CHAINLINK_EUR_USD);
        IOracle sgdOracle = IOracle(Polygon.CHAINLINK_SGD_USD);
        IOracle nzdOracle = IOracle(Polygon.CHAINLINK_NZD_USD);
        IOracle trybOracle = IOracle(Polygon.CHAINLINK_TRY_USD);
        IOracle ngncOracle = IOracle(Polygon.CHAINLINK_NGNC_USD);

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

        CurveFactoryV3.CurveInfo memory nzdsUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-nzds-usdc-v3",
                "dfx-nzds-usdc-v3",
                Polygon.NZDS,
                Polygon.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                nzdOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Polygon.NZDS_EPSILON,
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
        deployedCurveFactory.newCurve(cadcUsdcCurveInfo);
        deployedCurveFactory.newCurve(xsgdUsdcCurveInfo);
        deployedCurveFactory.newCurve(nzdsUsdcCurveInfo);
        deployedCurveFactory.newCurve(trybUsdcCurveInfo);
        deployedCurveFactory.newCurve(ngncUsdcCurveInfo);
        Zap zap = new Zap(address(deployedCurveFactory));
        Router router = new Router(address(deployedCurveFactory));
        vm.stopBroadcast();
    }
}

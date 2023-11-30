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

// MAINNET DEPLOYMENT
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
            Mainnet.WETH
        );
        // Attach CurveFactoryV3 to Assimilator
        deployedAssimFactory.setCurveFactory(address(deployedCurveFactory));

        // Deploy all new Curves
        _deployCadcUsdcCurve(deployedCurveFactory);
        _deployEurocUsdcCurve(deployedCurveFactory);
        _deployGbptUsdcCurve(deployedCurveFactory);
        _deployGyenUsdcCurve(deployedCurveFactory);
        _deployNzdsUsdcCurve(deployedCurveFactory);
        _deployTrybUsdcCurve(deployedCurveFactory);
        _deployXidrUsdcCurve(deployedCurveFactory);
        _deployXsgdUsdcCurve(deployedCurveFactory);

        Zap zap = new Zap(address(deployedCurveFactory));
        Router router = new Router(address(deployedCurveFactory));
        vm.stopBroadcast();
    }

    function _deployCadcUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle cadOracle = IOracle(Mainnet.CHAINLINK_CAD_USD);

        CurveFactoryV3.CurveInfo memory cadcUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-cadc-usdc-v3",
                "dfx-cadc-usdc-v3",
                Mainnet.CADC,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                cadOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.CADC_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(cadcUsdcCurveInfo);
    }

    function _deployEurocUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle eruoOracle = IOracle(Mainnet.CHAINLINK_EUR_USD);

        CurveFactoryV3.CurveInfo memory eurcUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-euroc-usdc-v3",
                "dfx-euroc-usdc-v3",
                Mainnet.EUROC,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                eruoOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.EUROC_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(eurcUsdcCurveInfo);
    }

    function _deployGbptUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle bptOracle = IOracle(Mainnet.CHAINLINK_BPT_USD);

        CurveFactoryV3.CurveInfo memory gbptUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-gbpt-usdc-v3",
                "dfx-gbpt-usdc-v3",
                Mainnet.GBPT,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                bptOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.GBPT_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(gbptUsdcCurveInfo);
    }

    function _deployGyenUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle yenOracle = IOracle(Mainnet.CHAINLINK_YEN_USD);

        CurveFactoryV3.CurveInfo memory gyenUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-gyen-usdc-v3",
                "dfx-gyen-usdc-v3",
                Mainnet.GYEN,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                yenOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.GYEN_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(gyenUsdcCurveInfo);
    }

    function _deployNzdsUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle nzdOracle = IOracle(Mainnet.CHAINLINK_NZD_USD);

        CurveFactoryV3.CurveInfo memory nzdsUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-nzds-usdc-v3",
                "dfx-nzds-usdc-v3",
                Mainnet.NZDS,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                nzdOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.NZDS_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(nzdsUsdcCurveInfo);
    }

    function _deployTrybUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle trybOracle = IOracle(Mainnet.CHAINLINK_TRY_USD);

        CurveFactoryV3.CurveInfo memory trybUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-tryb-usdc-v3",
                "dfx-tryb-usdc-v3",
                Mainnet.TRYB,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                trybOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.TRYB_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(trybUsdcCurveInfo);
    }

    function _deployXidrUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle idrOracle = IOracle(Mainnet.CHAINLINK_IDR_USD);

        CurveFactoryV3.CurveInfo memory xidrUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-xidr-usdc-v3",
                "dfx-xidr-usdc-v3",
                Mainnet.XIDR,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                idrOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.XIDR_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(xidrUsdcCurveInfo);
    }

    function _deployXsgdUsdcCurve(
        CurveFactoryV3 deployedCurveFactory
    ) internal {
        IOracle usdOracle = IOracle(Mainnet.CHAINLINK_USDC_USD);
        IOracle sgdOracle = IOracle(Mainnet.CHAINLINK_SGD_USD);

        CurveFactoryV3.CurveInfo memory xsgdUsdcCurveInfo = CurveFactoryV3
            .CurveInfo(
                "dfx-xsgd-usdc-v3",
                "dfx-xsgd-usdc-v3",
                Mainnet.XSGD,
                Mainnet.USDC,
                CurveParams.BASE_WEIGHT,
                CurveParams.QUOTE_WEIGHT,
                sgdOracle,
                usdOracle,
                CurveParams.ALPHA,
                CurveParams.BETA,
                CurveParams.MAX,
                Mainnet.XSGD_EPSILON,
                CurveParams.LAMBDA
            );

        deployedCurveFactory.newCurve(xsgdUsdcCurveInfo);
    }
}

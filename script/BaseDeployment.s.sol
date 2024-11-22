// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "./Addresses.sol";
import "./CurveParams.sol";

// Curve
import "../src/CurveVerifier.sol";

// Libraries
import "../src/Curve.sol";
import "../src/Config.sol";

// Factories
import "../src/CurveFactoryV3.sol";

// Zap
import "../src/Zap.sol";
import "../src/Router.sol";

// Base DEPLOYMENT
contract BaseV3DeploymentScript is Script {
    function run() external {
        address OWNER = vm.envAddress("OWNER");

        vm.startBroadcast();
        // first deploy the config
        int128 protocolFee = 50_000;
        Config config = new Config(protocolFee, OWNER);
        // Deploy Assimilator
        AssimilatorFactory deployedAssimFactory = new AssimilatorFactory(address(config));
        // Deploy CurveVerifier
        CurveVerifier verifier = new CurveVerifier(address(config));
        // Deploy CurveFactoryV3
        CurveFactoryV3 deployedCurveFactory =
            new CurveFactoryV3(address(deployedAssimFactory), address(config), Base.WETH, address(verifier));
        verifier.setCurveFactory((address(deployedCurveFactory)));
        // Attach CurveFactoryV3 to Assimilator
        deployedAssimFactory.setCurveFactory(address(deployedCurveFactory));
        IOracle usdcOracle = IOracle(Base.CHAINLINK_USDC_USD);
        IOracle eurcOracle = IOracle(Base.CHAINLINK_EURC_USD);
        CurveFactoryV3.CurveInfo memory eurcUsdcCurveInfo = CurveFactoryV3.CurveInfo(
            "DFX EURC/USDC v3 Pool",
            "dfx-eurc-usdc-v3",
            Base.EURC,
            Base.USDC,
            CurveParams.BASE_WEIGHT,
            CurveParams.QUOTE_WEIGHT,
            eurcOracle,
            usdcOracle,
            CurveParams.ALPHA,
            CurveParams.BETA,
            CurveParams.MAX,
            Base.EURC_EPSILON,
            CurveParams.LAMBDA
        );

        // Add oracles to verifier
        verifier.whitelistOracle(Base.CHAINLINK_USDC_USD);
        verifier.whitelistOracle(Base.CHAINLINK_EURC_USD);
        verifier.registerOracleWithToken(Base.CHAINLINK_USDC_USD, Base.USDC);
        verifier.registerOracleWithToken(Base.CHAINLINK_EURC_USD, Base.EURC);

        // Deploy all new Curves
        deployedCurveFactory.newCurve(eurcUsdcCurveInfo);
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

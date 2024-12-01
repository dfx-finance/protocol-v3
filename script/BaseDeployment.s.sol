// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ScriptTools} from "dss-test/ScriptTools.sol";

// Curve
import {CurveVerifier} from "../src/CurveVerifier.sol";

// Libraries
import {Curve} from "../src/Curve.sol";
import {Config} from "../src/Config.sol";

// Factories
import {AssimilatorFactory} from "../src/AssimilatorFactory.sol";
import {CurveFactoryV3} from "../src/CurveFactoryV3.sol";

// Zap
import {Zap} from "../src/Zap.sol";
import {Router} from "../src/Router.sol";

// Base DEPLOYMENT
contract BaseV3DeploymentScript is Script {
    using stdJson for string;
    using ScriptTools for string;

    string instanceId;
    string existingContracts;

    address WETH;

    function run() public {
        instanceId = vm.envOr("INSTANCE_ID", string("primary"));
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        address OWNER = vm.envAddress("OWNER");

        existingContracts = ScriptTools.readInput(instanceId);
        WETH = existingContracts.readAddress(".WETH");

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
            new CurveFactoryV3(address(deployedAssimFactory), address(config), WETH, address(verifier));
        verifier.setCurveFactory((address(deployedCurveFactory)));
        // Attach CurveFactoryV3 to Assimilator
        deployedAssimFactory.setCurveFactory(address(deployedCurveFactory));
        // // Deploy zap
        // Zap zap = new Zap(address(deployedCurveFactory));
        // // Deploy router
        // Router router = new Router(address(deployedCurveFactory));
        vm.stopBroadcast();

        // Save addresses
        ScriptTools.exportContract(instanceId, "config", address(config));
        ScriptTools.exportContract(instanceId, "assimilatorFactory", address(deployedAssimFactory));
        ScriptTools.exportContract(instanceId, "curveVerifier", address(verifier));
        ScriptTools.exportContract(instanceId, "curveFactory", address(deployedCurveFactory));
        // ScriptTools.exportContract(instanceId, "zap", address(zap));
        // ScriptTools.exportContract(instanceId, "router", address(router));
    }
}

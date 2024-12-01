// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {console} from "forge-std/Console.sol";
import {Script, stdJson} from "forge-std/Script.sol";
import {ScriptTools} from "dss-test/ScriptTools.sol";

import {ICurveFactory, CurveInfo} from "../../src/interfaces/ICurveFactory.sol";
import {ICurveVerifier} from "../../src/interfaces/ICurveVerifier.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {Curve} from "../../src/Curve.sol";
import {CurveFactoryV3} from "../../src/CurveFactoryV3.sol";
import {CurveVerifier} from "../../src/CurveVerifier.sol";
import {CurveParams} from "./CurveParams.sol";

import {ViewLiquidity} from "../../src/ViewLiquidity.sol";

contract EurcUsdcCurveDeploymentScript is Script {
    using stdJson for string;
    using ScriptTools for string;

    string instanceId;
    string existingContracts;
    string deployedContracts;

    address EURC;
    address USDC;
    address curveFactory;
    address curveVerifier;
    address eurcUsdOracle;
    address usdcUsdOracle;
    uint256 eurcUsdcEpsilon;

    function run() public {
        instanceId = vm.envOr("INSTANCE_ID", string("primary"));
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");

        existingContracts = ScriptTools.readInput(instanceId);
        EURC = existingContracts.readAddress(".EURC");
        USDC = existingContracts.readAddress(".USDC");
        eurcUsdOracle = existingContracts.readAddress(".CHAINLINK_EURC_USD");
        usdcUsdOracle = existingContracts.readAddress(".CHAINLINK_USDC_USD");
        eurcUsdcEpsilon = existingContracts.readUint(".EURC_USDC_EPSILON");

        deployedContracts = ScriptTools.readOutput(instanceId);
        curveFactory = deployedContracts.readAddress(".curveFactory");
        curveVerifier = deployedContracts.readAddress(".curveVerifier");

        IOracle eurcOracle = IOracle(eurcUsdOracle);
        IOracle usdcOracle = IOracle(usdcUsdOracle);

        CurveInfo memory eurcUsdcCurveInfo = CurveInfo(
            "Sage EURC/USDC v3",
            "sage-eurc-usdc-v3",
            EURC,
            USDC,
            CurveParams.BASE_WEIGHT,
            CurveParams.QUOTE_WEIGHT,
            eurcOracle,
            usdcOracle,
            CurveParams.ALPHA,
            CurveParams.BETA,
            CurveParams.MAX,
            eurcUsdcEpsilon,
            CurveParams.LAMBDA
        );

        // Add oracles to verifier
        ICurveVerifier verifier = ICurveVerifier(curveVerifier);
        ICurveFactory factory = ICurveFactory(curveFactory);

        vm.startBroadcast();
        verifier.whitelistOracle(usdcUsdOracle);
        verifier.whitelistOracle(eurcUsdOracle);
        verifier.registerOracleWithToken(usdcUsdOracle, USDC);
        verifier.registerOracleWithToken(eurcUsdOracle, EURC);
        // verifier.unregisterCurve(EURC, USDC);

        // Deploy curve
        Curve eurcUsdcCurve = factory.newCurve(eurcUsdcCurveInfo, true);
        vm.stopBroadcast();

        // Save addresses
        ScriptTools.exportContract(string.concat(instanceId, "-eurcUsdcCurve"), "eurcUsdcCurve", address(eurcUsdcCurve));
    }
}

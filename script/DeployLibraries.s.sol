// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ScriptTools} from "dss-test/ScriptTools.sol";

import {ABDKMath64x64} from "../src/lib/ABDKMath64x64.sol";
import {Assimilators} from "../src/Assimilators.sol";
import {CurveMath} from "../src/CurveMath.sol";
import {Curves} from "../src/Curves.sol";
import {Orchestrator} from "../src/Orchestrator.sol";
import {ProportionalLiquidity} from "../src/ProportionalLiquidity.sol";
import {NoDelegateCall} from "../src/lib/NoDelegateCall.sol";
import {Storage} from "../src/Storage.sol";
import {Swaps} from "../src/Swaps.sol";
import {UnsafeMath64x64} from "../src/lib/UnsafeMath64x64.sol";
import {ViewLiquidity} from "../src/ViewLiquidity.sol";

contract DeployLibraries is Script {
    using stdJson for string;
    using ScriptTools for string;

    string instanceId;

    function deploy(string memory name, bytes memory bytecode) public {
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        console.log(string.concat(name, " library deployed at:"), addr);

        // Save address
        instanceId = vm.envOr("INSTANCE_ID", string("primary"));
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", "true");
        ScriptTools.exportContract(string.concat(instanceId, "-libs"), name, addr);
    }

    function run() external {
        vm.startBroadcast();
        //// deploy("ABDKMath64x64", type(ABDKMath64x64).creationCode);
        deploy("Assimilators", type(Assimilators).creationCode);
        deploy("CurveMath", type(CurveMath).creationCode);
        deploy("Curves", type(Curves).creationCode);
        deploy("Orchestrator", type(Orchestrator).creationCode);
        deploy("ProportionalLiquidity", type(ProportionalLiquidity).creationCode);
        deploy("Storage", type(Storage).creationCode);
        deploy("Swaps", type(Swaps).creationCode);
        //// deploy("UnsafeMath64x64", type(UnsafeMath64x64).creationCode);
        deploy("ViewLiquidity", type(ViewLiquidity).creationCode);
        vm.stopBroadcast();
    }
}

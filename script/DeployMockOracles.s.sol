// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import {MockChainlinkOracle} from "../test/lib/MockChainlinkOracle.sol";

contract DeployMockOracles is Script {
    function run() external {
        vm.startBroadcast();
        MockChainlinkOracle mockOracle0 =
            new MockChainlinkOracle(0x808456652fdb597867f38412077A9182bf77359F, "Mock EURC Oracle", 8, 105e6);
        console.log("Mock EURC Oracle deployed at:", address(mockOracle0));

        MockChainlinkOracle mockOracle1 =
            new MockChainlinkOracle(0x036CbD53842c5426634e7929541eC2318f3dCF7e, "Mock USDC Oracle", 8, 1e8);
        console.log("Mock USDC Oracle deployed at:", address(mockOracle1));
        vm.stopBroadcast();
    }
}

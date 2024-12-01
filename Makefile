include .env

mock-oracles		:; forge script script/mock/DeployMockOracles.s.sol:DeployMockOracles --rpc-url ${BASE_SEPOLIA_RPC_URL} --account sage-base-deploy --sender ${DEPLOYER} --broadcast --verify
libraries			:; forge script script/DeployLibraries.s.sol:DeployLibraries --rpc-url ${BASE_SEPOLIA_RPC_URL} --account sage-base-deploy --sender ${DEPLOYER} --broadcast --verify

v3-base				:; forge script script/BaseDeployment.s.sol:BaseV3DeploymentScript --rpc-url ${BASE_SEPOLIA_RPC_URL} --account sage-base-deploy --sender ${DEPLOYER} --broadcast --verify
eurc-usdc-pool-base :; forge script script/curves/DeployEurcUsdcCurve.s.sol:EurcUsdcCurveDeploymentScript --rpc-url ${BASE_SEPOLIA_RPC_URL} --account sage-base-deploy --sender ${DEPLOYER} --broadcast --verify

include .env

v3-base	:; forge script script/BaseDeployment.s.sol:BaseV3DeploymentScript --rpc-url ${BASE_RPC_URL} --account dfx-base-deploy --sender ${DEPLOYER} --slow --broadcast --verify

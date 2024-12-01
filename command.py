import json
import os

chain_id = 84532
optimizations = 200
name = "Sage EURC/USDC v3"
symbol = "sage-eurc-usdc-v3"
base_currency = "0x808456652fdb597867f38412077A9182bf77359F"
base_assimilator = "0xE1E78668b073a7Bcd61AD47B763E9c48d1105a06"
quote_currency = "0x036CbD53842c5426634e7929541eC2318f3dCF7e"
quote_assimilator = "0xBff7d71D76f9F831Fdc442Cf39bF0178fCFD9861"

api_key = "RKI4JN1SGDEIWQQ1XF83CV24A8W53K4ISB"

curve_data = None
with open(f"./script/output/{chain_id}/primary-eurcUsdcCurve-latest.json") as curve_f:
    curve_data = json.load(curve_f)
curve = curve_data["eurcUsdcCurve"]

protocol_data = None
with open(f"./script/output/{chain_id}/primary-latest.json") as protocol_f:
    protocol_data = json.load(protocol_f)
factory = protocol_data["curveFactory"]
config = protocol_data["config"]

libs_data = None
with open(f"./script/output/{chain_id}/primary-libs-latest.json") as libs_f:
    libs_data = json.load(libs_f)

# abdkMath64x64 = libs_data["ABDKMath64x64"]
abdkMath64x64 = "0x752043a11a632B7383CE23e7175eA9A9076a6CB7"
# assimilators = libs_data["Assimilators"]
assimilators = "0x4ff4d77051c585a09CE4945D51482c0d14E41dd3"
# curves = libs_data["Curves"]
# curveMath = libs_data["CurveMath"]
curveMath = "0x003fc9D2BA1755Cb07896a9e94384Cc4DaefAb39"
# orchestrator = libs_data["Orchestrator"]
orchestrator = "0x07cD3b73e47c3d55AFe861f008A32A7139eE7096"
# proportionalLiquidity = libs_data["ProportionalLiquidity"]
# proportionalLiquidity = "0x744Cb7644F4fF667CA53B9E6c948bE1E151D03bF"
# storage = libs_data["Storage"]
# swaps = libs_data["Swaps"]
# swaps = "0x83FF2F65346d6eBE580965796A7f097Cce21071E"
# unsafeMath64x64 = libs_data["UnsafeMath64x64"]
# viewLiquidity = libs_data["ViewLiquidity"]
# viewLiquidity = "0xD6f11BcB179cB12ac9Ae5476268cB3E995c6c45C"

# cmd = f"""forge verify-contract \\
#     --chain {chain_id} \\
#     --num-of-optimizations {optimizations} \\
#     --watch \\
#     --constructor-args $(cast abi-encode "constructor(string,string,address[],uint256[],address,address)" \\
#         "{name}" \\
#         "{symbol}" \\
#         "[{base_currency},{base_assimilator},{base_currency},{base_assimilator},{base_currency},{quote_currency},{quote_assimilator},{quote_currency},{quote_assimilator},{quote_currency}]" \\
#         "[500000000000000000,500000000000000000]" \\
#         "{factory}" \\
#         "{config}") \\
#     --etherscan-api-key {api_key} \\
#     --libraries ./src/lib/ABDKMath64x64.sol:ABDKMath64x64:{abdkMath64x64} \\
#     --libraries ./src/Curves.sol:Curves:{curves} \\
#     --libraries ./src/CurveMath.sol:CurveMath:{curveMath} \\
#     --libraries ./src/Orchestrator.sol:Orchestrator:{orchestrator} \\
#     --libraries ./src/Storage.sol:Storage:{storage} \\
#     --libraries ./src/Swaps.sol:Swaps:{swaps} \\
#     --libraries ./src/lib/UnsafeMath64x64.sol:UnsafeMath64x64:{unsafeMath64x64} \\
#     --libraries ./src/ProportionalLiquidity.sol:ProportionalLiquidity:{proportionalLiquidity} \\
#     --libraries ./src/ViewLiquidity.sol:ViewLiquidity:{viewLiquidity} \\
#     {curve} \\
#     Curve
# """

cmd = f"""forge verify-contract \\
    --chain {chain_id} \\
    --num-of-optimizations {optimizations} \\
    --watch \\
    --constructor-args $(cast abi-encode "constructor(string,string,address[],uint256[],address,address)" \\
        "{name}" \\
        "{symbol}" \\
        "[{base_currency},{base_assimilator},{base_currency},{base_assimilator},{base_currency},{quote_currency},{quote_assimilator},{quote_currency},{quote_assimilator},{quote_currency}]" \\
        "[500000000000000000,500000000000000000]" \\
        "{factory}" \\
        "{config}") \\
    --etherscan-api-key {api_key} \\
    --libraries ./src/lib/ABDKMath64x64.sol:ABDKMath64x64:{abdkMath64x64} \\
    --libraries ./src/Assimilators.sol:Assimilators:{assimilators} \\
    --libraries ./src/CurveMath.sol:CurveMath:{curveMath} \\
    --libraries ./src/Orchestrator.sol:CurveMath:{orchestrator} \\
    {curve} \\
    Curve
"""

print(cmd)
os.system(cmd)

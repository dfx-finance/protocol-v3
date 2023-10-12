// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../src/interfaces/IAssimilator.sol";
import "../src/interfaces/IOracle.sol";
import "../src/interfaces/IERC20Detailed.sol";
import "../src/AssimilatorFactory.sol";
import "../src/CurveFactoryV3.sol";
import "../src/Curve.sol";
import "../src/Config.sol";
import "../src/Structs.sol";
import "../src/Router.sol";
import "../src/Zap.sol";
import "../src/lib/ABDKMath64x64.sol";

import "./lib/MockUser.sol";
import "./lib/CheatCodes.sol";
import "./lib/Address.sol";
import "./lib/CurveParams.sol";
import "./lib/MockChainlinkOracle.sol";
import "./lib/MockOracleFactory.sol";
import "./lib/MockToken.sol";
import "./lib/FeeOnTransfer.sol";

import "./utils/Utils.sol";

import "forge-std/Test.sol";
import "forge-std/StdAssertions.sol";

contract PolygonDeployedTest is Test {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Detailed;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Utils utils;

    // account order is lp provider, trader, treasury
    MockUser[] public accounts;

    Curve public cadcCurve;
    Zap public zap;
    Router public router;

    IERC20Detailed public cadc;
    IERC20Detailed public usdc;
    IERC20Detailed public xsgd;

    uint256 public constant mintAmt = 100000;

    function setUp() public {
        utils = new Utils();
        // init mock accounts
        for (uint256 i = 0; i < 4; ++i) {
            accounts.push(new MockUser());
        }
        cadcCurve = Curve(payable(0xE15d4757fa0AFA3F6ED0752afF7bd776127E0045));
        zap = Zap(0x2420D5B50C268c20F6eDb34Df93ceD68F57cF493);
        router = Router(payable(0xE325dC2C5968105b63c2Db75333126a66fDf7345));
        cadc = IERC20Detailed(0x9de41aFF9f55219D5bf4359F167d1D0c772A396D);
        usdc = IERC20Detailed(0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359);
        xsgd = IERC20Detailed(0xDC3326e71D45186F113a2F448984CA0e8D201995);

        // mint tokens to account 0 - LPer & 1 - trader
        deal(address(cadc), address(accounts[0]), mintAmt * 1e18);
        deal(address(cadc), address(accounts[1]), mintAmt * 1e18);
        deal(address(usdc), address(accounts[0]), mintAmt * 1e6);
        deal(address(usdc), address(accounts[1]), mintAmt * 1e6);

        deal(address(xsgd), address(accounts[0]), mintAmt * 1e6);
        // approve curve, router & zap
        cheats.startPrank(address(accounts[0]));
        cadc.approve(address(cadcCurve), type(uint256).max);
        cadc.approve(address(router), type(uint256).max);
        cadc.approve(address(zap), type(uint256).max);
        usdc.approve(address(cadcCurve), type(uint256).max);
        usdc.approve(address(router), type(uint256).max);
        usdc.approve(address(zap), type(uint256).max);
        cheats.stopPrank();
        cheats.startPrank(address(accounts[1]));
        cadc.approve(address(cadcCurve), type(uint256).max);
        cadc.approve(address(router), type(uint256).max);
        cadc.approve(address(zap), type(uint256).max);
        usdc.approve(address(cadcCurve), type(uint256).max);
        usdc.approve(address(router), type(uint256).max);
        usdc.approve(address(zap), type(uint256).max);
        cheats.stopPrank();
    }

    function testCadcCurve() public {
        cheats.startPrank(address(accounts[0]));
        uint256 _curves;
        uint256[] memory _deposits = new uint256[](2);
        (_curves, _deposits) = cadcCurve.viewDeposit(10 * 1e18);
        console.logString("view deposit for 10*1e18");
        console.log(_curves);
        console.log(_deposits[0]);
        console.log(_deposits[1]);
        cadcCurve.deposit(
            10 * 1e18,
            (_deposits[0] * 9) / 10,
            (_deposits[1] * 9) / 10,
            (_deposits[0] * 11) / 10,
            (_deposits[1] * 11) / 10,
            block.timestamp + 60
        );
        cheats.stopPrank();
    }

    function testXsgdCurve() public {}
}

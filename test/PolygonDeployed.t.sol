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

contract DepositTest is Test {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Detailed;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Utils utils;

    // account order is lp provider, trader, treasury
    MockUser[] public accounts;

    Curve public cadcCurve;
    Curve public trybCurve;
    Curve public ngncCurve;
    // tokens
    IERC20Detailed public cadc;
    IERC20Detailed public usdc;
    IERC20Detailed public tryb;
    IERC20Detailed public ngnc;

    // oracles
    IOracle public cadcOracle;
    IOracle public usdcOracle;
    IOracle public trybOracle;
    IOracle public ngncOracle;

    // protocol contracts
    Config public config;
    CurveFactoryV3 public curveFactory;
    AssimilatorFactory public assimFactory;
    Zap public zap;
    Router public router;

    // decimals
    mapping(address => uint256) decimals;

    function setUp() public {
        utils = new Utils();
        // init mock accounts
        for (uint256 i = 0; i < 4; ++i) {
            accounts.push(new MockUser());
        }
        // init tokens
        cadc = IERC20Detailed(Polygon.CADC);
        usdc = IERC20Detailed(Polygon.USDC);
        tryb = IERC20Detailed(Polygon.TRYB);
        ngnc = IERC20Detailed(Polygon.NGNC);

        //init oracles
        cadcOracle = IOracle(Polygon.CHAINLINK_CAD_USD);
        usdcOracle = IOracle(Polygon.CHAINLINK_USDC);
        trybOracle = IOracle(Polygon.CHAINLINK_TRY_USD);
        ngncOracle = IOracle(Polygon.CHAINLINK_NGNC_USD);

        // deploy protocol
        cheats.startPrank(address(accounts[2]));
        config = new Config(50000, address(accounts[2]));
        console.log("config : ", address(config));
        assimFactory = new AssimilatorFactory(address(config));
        console.log("assimFactory : ", address(assimFactory));
        curveFactory = new CurveFactoryV3(
            address(assimFactory),
            address(config),
            Polygon.WMATIC
        );
        console.log("curveFactory : ", address(curveFactory));
        assimFactory.setCurveFactory(address(curveFactory));
        zap = new Zap(address(curveFactory));
        console.log("zap : ", address(zap));
        router = new Router(address(curveFactory));
        console.log("router : ", address(router));
        cheats.stopPrank();
        // deploy cadc-usdc curve
        cadcCurve = createCurve(
            "cadc-usdc",
            address(cadc),
            address(usdc),
            address(cadcOracle),
            address(usdcOracle)
        );
    }

    function testCadcCurve() public {
        // // try first deposit
        // (uint256 baseAmt, uint256 usdAmt, uint256 lptAmt) = zap
        //     .calcMaxBaseForDeposit(address(cadcCurve), 10000e16);
        // console.log(baseAmt, usdAmt, lptAmt);
        // view deposit using curve
        uint256 lptAmt;
        uint256[] memory outs = new uint256[](2);
        (lptAmt, outs) = cadcCurve.viewDeposit(175000 * 1e18);
        console.log("first deposit : ", lptAmt, outs[0], outs[1]);
        cheats.startPrank(address(accounts[0]));
        cadcCurve.deposit(
            175000 * 1e18,
            (outs[0] * 9) / 10,
            (outs[1] * 9) / 10,
            outs[0],
            outs[1],
            block.timestamp + 60
        );
        console.log("pair token balances after first deposit");
        console.log(cadc.balanceOf(address(cadcCurve)));
        console.log(usdc.balanceOf(address(cadcCurve)));
        uint256 userLptAfterFirstDeposit = IERC20Detailed(address(cadcCurve))
            .balanceOf(address(accounts[0]));
        cheats.stopPrank();
        (lptAmt, outs) = cadcCurve.viewDeposit(175000 * 1e18);
        console.log("second deposit : ", lptAmt, outs[0], outs[1]);
        cheats.startPrank(address(accounts[0]));
        console.log("before second deposit, user balances");
        console.log(usdc.balanceOf(address(accounts[0])));
        console.log(cadc.balanceOf(address(accounts[0])));
        cadcCurve.deposit(
            lptAmt,
            (outs[1] * 99) / 100,
            (outs[0] * 99) / 100,
            outs[1],
            outs[0],
            block.timestamp + 60
        );
        console.log("pair token balances after second deposit");
        console.log(cadc.balanceOf(address(cadcCurve)));
        console.log(usdc.balanceOf(address(cadcCurve)));
        cheats.stopPrank();
        uint256 userLptAfterSecondDeposit = IERC20Detailed(address(cadcCurve))
            .balanceOf(address(accounts[0]));
        console.log("user lpt balance");
        console.log(
            userLptAfterFirstDeposit,
            userLptAfterSecondDeposit,
            userLptAfterSecondDeposit - userLptAfterFirstDeposit
        );
        // now test zap
        (uint256 baseAmt, uint256 baseUsdAmt, uint256 baseLptAmt) = zap
            .calcMaxBaseForDeposit(address(cadcCurve), 1000 * 1e6);
        console.log("calcMaxBase");
        console.log(baseAmt, baseUsdAmt, baseLptAmt);
        (uint256 quoteAmt, uint256 quoteUsdAmt, uint256 quoteLptAmt) = zap
            .calcMaxQuoteForDeposit(address(cadcCurve), 1000 * 1e18);
        console.log("calcMaxQuote");
        console.log(quoteAmt, quoteUsdAmt, quoteLptAmt);
    }

    // helper
    function createCurve(
        string memory name,
        address base,
        address quote,
        address baseOracle,
        address quoteOracle
    ) public returns (Curve) {
        cheats.startPrank(address(accounts[2]));
        CurveFactoryV3.CurveInfo memory curveInfo = CurveFactoryV3.CurveInfo(
            string(abi.encode("dfx-curve-", name)),
            string(abi.encode("lp-", name)),
            base,
            quote,
            DefaultCurve.BASE_WEIGHT,
            DefaultCurve.QUOTE_WEIGHT,
            IOracle(baseOracle),
            IOracle(quoteOracle),
            DefaultCurve.ALPHA,
            DefaultCurve.BETA,
            DefaultCurve.MAX,
            DefaultCurve.EPSILON,
            DefaultCurve.LAMBDA
        );
        Curve _curve = curveFactory.newCurve(curveInfo);
        console.log(name, " curve : ", address(_curve));
        cheats.stopPrank();
        // now mint base token, update decimals map
        uint256 mintAmt = 300_000_000_000;
        uint256 baseDecimals = utils.tenToPowerOf(
            IERC20Detailed(base).decimals()
        );
        decimals[base] = baseDecimals;
        deal(base, address(accounts[0]), mintAmt.mul(baseDecimals));
        // now mint quote token, update decimals map
        uint256 quoteDecimals = utils.tenToPowerOf(
            IERC20Detailed(quote).decimals()
        );
        decimals[quote] = quoteDecimals;
        deal(quote, address(accounts[0]), mintAmt.mul(quoteDecimals));
        // now approve the deployed curve
        cheats.startPrank(address(accounts[0]));
        IERC20Detailed(base).safeApprove(address(_curve), type(uint256).max);
        IERC20Detailed(quote).safeApprove(address(_curve), type(uint256).max);
        cheats.stopPrank();
        return _curve;
    }
}

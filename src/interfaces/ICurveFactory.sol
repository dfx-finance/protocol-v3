// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IAssimilatorFactory} from "./IAssimilatorFactory.sol";
import {IOracle} from "./IOracle.sol";
import {Curve} from "../Curve.sol";

struct CurveInfo {
    string _name;
    string _symbol;
    address _baseCurrency;
    address _quoteCurrency;
    uint256 _baseWeight;
    uint256 _quoteWeight;
    IOracle _baseOracle;
    IOracle _quoteOracle;
    uint256 _alpha;
    uint256 _beta;
    uint256 _feeAtHalt;
    uint256 _epsilon;
    uint256 _lambda;
}

interface ICurveFactory {
    function getProtocolFee() external view returns (int128);

    function getProtocolTreasury() external view returns (address);

    function assimilatorFactory() external view returns (IAssimilatorFactory);

    function wETH() external view returns (address);

    function isSageCurve(address) external view returns (bool);

    function newCurve(CurveInfo memory _info, bool overwrite) external returns (Curve);

    function newCurve(CurveInfo memory _info) external returns (Curve);
}

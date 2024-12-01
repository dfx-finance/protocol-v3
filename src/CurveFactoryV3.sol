// SPDX-License-Identifier: MIT

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is disstributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
pragma solidity ^0.8.27;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IAssimilatorFactory} from "./interfaces/IAssimilatorFactory.sol";
import {IConfig} from "./interfaces/IConfig.sol";
import {ICurveFactory, CurveInfo} from "./interfaces/ICurveFactory.sol";
import {ICurveVerifier} from "./interfaces/ICurveVerifier.sol";
import {AssimilatorV3} from "./assimilators/AssimilatorV3.sol";
import {Curve} from "./Curve.sol";
import {AssimilatorFactory} from "./AssimilatorFactory.sol";

contract CurveFactoryV3 is ICurveFactory, Ownable {
    using Address for address;

    IAssimilatorFactory public immutable assimilatorFactory;
    IConfig public immutable config;
    ICurveVerifier public immutable curveVerifier;

    event NewCurve(address indexed caller, bytes32 indexed id, address indexed curve);

    mapping(bytes32 => address) public curves;
    mapping(address => bool) public isSageCurve;

    address public immutable wETH;

    struct CurveIDPair {
        bytes32 curveId;
        bytes32 curveIdReversed;
    }

    constructor(address _assimFactory, address _config, address _weth, address _verifier) {
        require(_assimFactory.isContract(), "invalid-assimFactory");
        assimilatorFactory = IAssimilatorFactory(_assimFactory);
        require(_config.isContract(), "invalid-config");
        config = IConfig(_config);
        wETH = _weth;
        require(address(_verifier) != address(0), "invalid-curveVerifier");
        curveVerifier = ICurveVerifier(_verifier);
    }

    function getProtocolFee() external view virtual override returns (int128) {
        return config.getProtocolFee();
    }

    function getProtocolTreasury() public view virtual override returns (address) {
        return config.getProtocolTreasury();
    }

    function getCurve(address _baseCurrency, address _quoteCurrency) external view returns (address payable) {
        CurveIDPair memory idPair = generateCurveID(_baseCurrency, _quoteCurrency);
        return payable(curves[idPair.curveId]);
    }

    function newCurve(CurveInfo memory _info, bool overwrite) public returns (Curve) {
        require(_info._quoteCurrency != address(0), "quote-currency-zero-address");
        require(_info._baseCurrency != _info._quoteCurrency, "quote-base-currencies-same");
        require((_info._baseWeight + _info._quoteWeight) == 1e18, "invalid-weights");
        require(
            curveVerifier.verifyNewCurve(
                _info._baseCurrency, address(_info._baseOracle), _info._quoteCurrency, address(_info._quoteOracle)
            )
        );

        CurveIDPair memory idPair = generateCurveID(_info._baseCurrency, _info._quoteCurrency);
        if (!overwrite) {
            if (curves[idPair.curveId] != address(0) || curves[idPair.curveIdReversed] != address(0)) {
                revert("pair-exists");
            }
        }
        AssimilatorV3 _baseAssim;
        _baseAssim = (assimilatorFactory.getAssimilator(_info._baseCurrency, _info._quoteCurrency));
        if (address(_baseAssim) == address(0)) {
            _baseAssim = assimilatorFactory.newAssimilator(
                _info._quoteCurrency,
                _info._baseOracle,
                _info._baseCurrency,
                IERC20Metadata(_info._baseCurrency).decimals()
            );
        }
        AssimilatorV3 _quoteAssim;
        _quoteAssim = (assimilatorFactory.getAssimilator(_info._quoteCurrency, _info._baseCurrency));
        if (address(_quoteAssim) == address(0)) {
            _quoteAssim = assimilatorFactory.newAssimilator(
                _info._baseCurrency,
                _info._quoteOracle,
                _info._quoteCurrency,
                IERC20Metadata(_info._quoteCurrency).decimals()
            );
        }

        address[] memory _assets = new address[](10);
        uint256[] memory _assetWeights = new uint256[](2);

        // Base Currency
        _assets[0] = _info._baseCurrency;
        _assets[1] = address(_baseAssim);
        _assets[2] = _info._baseCurrency;
        _assets[3] = address(_baseAssim);
        _assets[4] = _info._baseCurrency;

        // Quote Currency (typically USDC)
        _assets[5] = _info._quoteCurrency;
        _assets[6] = address(_quoteAssim);
        _assets[7] = _info._quoteCurrency;
        _assets[8] = address(_quoteAssim);
        _assets[9] = _info._quoteCurrency;

        // Weights
        _assetWeights[0] = _info._baseWeight;
        _assetWeights[1] = _info._quoteWeight;

        // New curve
        Curve curve = new Curve(_info._name, _info._symbol, _assets, _assetWeights, address(this), address(config));
        curve.setParams(_info._alpha, _info._beta, _info._feeAtHalt, _info._epsilon, _info._lambda);
        curves[idPair.curveId] = address(curve);
        curves[idPair.curveIdReversed] = address(curve);
        isSageCurve[address(curve)] = true;

        // Register on verifier
        curveVerifier.registerCurve(_info._baseCurrency, _info._quoteCurrency);

        emit NewCurve(msg.sender, idPair.curveId, address(curve));
        return curve;
    }

    function newCurve(CurveInfo memory _info) public returns (Curve) {
        return newCurve(_info, false);
    }

    function generateCurveID(address _base, address _quote) public pure returns (CurveIDPair memory) {
        CurveIDPair memory pair;
        pair.curveId = keccak256(abi.encode(_base, _quote));
        pair.curveIdReversed = keccak256(abi.encode(_quote, _base));
        return pair;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ICurveVerifier {
    function config() external view returns (address config_);

    function factory() external view returns (address factory_);

    function owner() external view returns (address owner_);

    function setCurveFactory(address factory) external;

    function oracleToToken(address oracle) external view returns (bool token);

    function isOracleWhitelisted(address oracle) external view returns (bool);

    function isOracleRegistered(address oracle, address token) external view returns (bool);

    function isTokensRegistered(address base, address quote) external view returns (bool);

    function verifyNewCurve(address base, address quote, address baseOracle, address quoteOracle)
        external
        view
        returns (bool);

    function whitelistManager(address manager) external;

    function blacklistManager(address manager) external;

    function whitelistOracle(address oracle) external;

    function registerOracleWithToken(address oracle, address token) external;

    function registerTokens(address base, address owner) external;
}

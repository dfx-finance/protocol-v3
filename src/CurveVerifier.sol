// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/IConfig.sol";

contract CurveVerifier {
    using Address for address;

    event OracleWhitelisted(address indexed oracle);
    event OracleRegistered(address indexed oracle, address indexed tokenContract);
    event TokensRegistered(address indexed _base, address indexed _quote);
    event ManagerWhitelisted(address indexed manager);
    event ManagerBlacklisted(address indexed manager);

    mapping(address => bool) public whitelistedOracles;
    mapping(address => address) public oracleToToken;
    mapping(address => mapping(address => bool)) public tokensRegistered;
    mapping(address => bool) public managers;

    address public immutable config;
    address public factory;

    modifier onlyOwner() {
        require(msg.sender == owner(), "Unauthorized");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "Not factory");
        _;
    }

    modifier onlyManager() {
        require(managers[msg.sender] == true, "Not manager");
        _;
    }

    constructor(address _config) {
        require(_config.isContract(), "Config invalid");
        config = _config;

        managers[owner()] = true;
    }

    function owner() public view returns (address) {
        return IConfig(config).getProtocolTreasury();
    }

    function isOracleWhitelisted(address _oracle) public view returns (bool) {
        return whitelistedOracles[_oracle];
    }

    function isOracleRegistered(address _oracle, address _token) public view returns (bool) {
        return whitelistedOracles[_oracle] && oracleToToken[_oracle] == _token;
    }

    function isTokensRegistered(address _base, address _quote) public view returns (bool) {
        return tokensRegistered[_base][_quote];
    }

    function setCurveFactory(address _factory) external onlyOwner {
        require(_factory.isContract(), "Factory invalid");
        factory = _factory;
    }

    function whitelistManager(address _manager) external onlyOwner {
        require(managers[_manager], "Manager already whitelisted");
        managers[_manager] = true;
        emit ManagerWhitelisted(_manager);
    }

    function blacklistManager(address _manager) external onlyOwner {
        require(managers[_manager], "Manager not whitelisted");
        managers[_manager] = false;
        emit ManagerBlacklisted(_manager);
    }

    function verifyNewCurve(address base, address baseOracle, address quote, address quoteOracle)
        external
        view
        returns (bool success)
    {
        require(baseOracle != address(0) && quoteOracle != address(0), "oracle-zero-address");
        require(isTokensRegistered(base, quote) == false, "token-pair-exists");
        require(isOracleRegistered(baseOracle, base), "invalid-base-oracle");
        require(isOracleRegistered(quoteOracle, quote), "invalid-quote-oracle");
        return true;
    }

    function whitelistOracle(address _oracle) external onlyManager {
        require(!whitelistedOracles[_oracle], "CurveVerifier: Oracle already whitelisted");
        whitelistedOracles[_oracle] = true;
        emit OracleWhitelisted(_oracle);
    }

    function registerOracleWithToken(address _oracle, address _tokenContract) external onlyManager {
        require(whitelistedOracles[_oracle], "CurveVerifier: Oracle not whitelisted");
        oracleToToken[_oracle] = _tokenContract;
        emit OracleRegistered(_oracle, _tokenContract);
    }

    function registerTokens(address _base, address _quote) external onlyFactory {
        require(!tokensRegistered[_base][_quote] && !tokensRegistered[_quote][_base], "Already registered");
        tokensRegistered[_base][_quote] = true;
        tokensRegistered[_quote][_base] = true;
        emit TokensRegistered(_base, _quote);
    }
}

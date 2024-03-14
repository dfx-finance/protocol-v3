// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CurveVerifier {
    mapping(address => bool) public curveContracts;
    mapping(address => bool) public whitelistedOracles;
    mapping(address => address) public oracleToToken;
    mapping(address => mapping(address => bool)) public tokensRegistered;
    mapping(address => bool) public isManager;
    address public factory;
    address public owner;

    event CurveContractRegistered(address indexed curveContract);
    event OracleWhitelisted(address indexed oracle);
    event OracleRegistered(
        address indexed oracle,
        address indexed tokenContract
    );
    event TokensRegistered(address indexed _base, address indexed _quote);
    event ManagerWhitelisted(address indexed manager);
    event ManagerBlacklisted(address indexed manager);

    modifier onlyManager() {
        require(isManager[msg.sender], "Not Manager");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "Not Factory");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function whitelistManager(address _manager) external onlyOwner {
        require(!isManager[_manager], "Manager already whitelisted");
        isManager[_manager] = true;
        emit ManagerWhitelisted(_manager);
    }

    function blacklistManager(address _manager) external onlyOwner {
        require(isManager[_manager], "Manager not whitelisted");
        isManager[_manager] = false;
        emit ManagerBlacklisted(_manager);
    }

    function isCurveContractRegistered(
        address _curveContract
    ) external view returns (bool) {
        return curveContracts[_curveContract];
    }

    function isOracleWhitelisted(address _oracle) external view returns (bool) {
        return whitelistedOracles[_oracle];
    }

    function isOracleRegistered(
        address _token,
        address _oracle
    ) external view returns (bool) {
        return whitelistedOracles[_oracle] && oracleToToken[_oracle] == _token;
    }

    function isTokensRegistered(
        address _base,
        address _quote
    ) external view returns (bool) {
        return tokensRegistered[_base][_quote];
    }

    function registerCurveContract(
        address _curveContract
    ) external onlyManager {
        require(
            !curveContracts[_curveContract],
            "CurveVerifier: Curve contract already registered"
        );
        curveContracts[_curveContract] = true;
        emit CurveContractRegistered(_curveContract);
    }

    function whitelistOracle(address _oracle) external onlyManager {
        require(
            !whitelistedOracles[_oracle],
            "CurveVerifier: Oracle already whitelisted"
        );
        whitelistedOracles[_oracle] = true;
        emit OracleWhitelisted(_oracle);
    }

    function registerOracleWithToken(
        address _oracle,
        address _tokenContract
    ) external onlyManager {
        require(
            whitelistedOracles[_oracle],
            "CurveVerifier: Oracle not whitelisted"
        );
        oracleToToken[_oracle] = _tokenContract;
        emit OracleRegistered(_oracle, _tokenContract);
    }

    function registerTokens(
        address _base,
        address _quote
    ) external onlyManager {
        require(
            !tokensRegistered[_base][_quote] &&
                !tokensRegistered[_quote][_base],
            "Already registered"
        );
        tokensRegistered[_base][_quote] = true;
        tokensRegistered[_quote][_base] = true;
        emit TokensRegistered(_base, _quote);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../src/interfaces/IOracle.sol";

contract MockChainlinkOracle is IOracle {
    string public name;
    uint8 public override decimals;
    string public override description;
    address public constant dummyAddress = address(0);
    address public immutable underlying;
    int256 public immutable price;

    // dummy constructor
    constructor(address _token, string memory _name, uint8 _decimals, int256 _price) {
        underlying = _token;
        name = _name;
        decimals = _decimals;
        description = string(abi.encodePacked("this is a price feed for ", name));
        price = _price;
    }

    function getUnderlyingToken() external view returns (address) {
        return underlying;
    }

    // override I oracle interface functions
    function acceptOwnership() external override {}

    function accessController() external pure override returns (address) {
        return dummyAddress;
    }

    function aggregator() external pure override returns (address) {
        return dummyAddress;
    }

    function confirmAggregator(address _aggregator) external override {}

    function getAnswer(uint256) external view override returns (int256) {
        return price;
    }

    function getRoundData(uint80)
        external
        pure
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = 0;
        answer = 0;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;
    }

    function getTimestamp(uint256) external view override returns (uint256) {
        return block.timestamp;
    }

    function latestAnswer() external view override returns (int256) {
        return price;
    }

    function latestRound() external pure override returns (uint256) {
        return 0;
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = 0;
        answer = price;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;
    }

    function latestTimestamp() external pure override returns (uint256) {
        return 0;
    }

    function owner() external pure override returns (address) {
        return dummyAddress;
    }

    function phaseAggregators(uint16) external pure override returns (address) {
        return dummyAddress;
    }

    function phaseId() external pure override returns (uint16) {
        return 0;
    }

    function proposeAggregator(address _aggregator) external override {}

    function proposedAggregator() external pure override returns (address) {
        return dummyAddress;
    }

    function proposedGetRoundData(uint80)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = 0;
        answer = price;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;
    }

    function proposedLatestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = 0;
        answer = price;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;
    }

    function setController(address _accessController) external override {}

    function transferOwnership(address _to) external override {}

    function version() external pure override returns (uint256) {
        return 0;
    }
}

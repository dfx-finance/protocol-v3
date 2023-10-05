// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract MockUser {
    constructor() {}

    receive() external payable {}

    function call(address _a, bytes memory _b) public payable {
        (bool a, ) = _a.call{value: msg.value}(_b);
        require(a, "fail");
    }
}

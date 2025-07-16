//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

contract SimpleCalculator {
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a + b;
        return result;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a - b;
        return result;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a / b;
        return result;
    }
}

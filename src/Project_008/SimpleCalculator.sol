// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleCalculator {
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        return a - b;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "can't divide with zero");
        return a / b;
    }

    function modulo(uint256 a, uint256 b) public pure returns (uint256) {
        return a % b;
    }

    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }

    function addInt(int256 a, int256 b) public pure returns (int256) {
        return a + b;
    }

    function subtractInt(int256 a, int256 b) public pure returns (int256) {
        return a - b;
    }

    function multiplyInt(int256 a, int256 b) public pure returns (int256) {
        return a * b;
    }

    function divideInt(int256 a, int256 b) public pure returns (int256) {
        require(b != 0, "can't divide with zero");
        return a / b;
    }

    function moduloInt(int256 a, int256 b) public pure returns (int256) {
        return a % b;
    }

    function powerInt(int256 base, uint256 exponent) public pure returns (int256) {
        require(exponent >= 0, "exponent must be non-negative");
        int256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }
}

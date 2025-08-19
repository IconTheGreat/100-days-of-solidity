//SPDX-License-Identifier: MIT

import {Test} from "forge-std/Test.sol";
import {ETHStaking} from "../../src/Project_1/ETHStaking.sol";

pragma solidity ^0.8.19;

contract ETHStakingTest is Test {
    ETHStaking staking;
    address icon = address(1);
    address great = address(2);
    address owner;

    function setUp() public {
        staking = new ETHStaking();
        owner = staking.owner();
        vm.deal(icon, 10 ether);
        vm.deal(great, 10 ether);
    }

    function testStake() public {
        vm.prank(icon);
        staking.stake{value: 1 ether}();
        assertEq(staking.balances(icon), 1 ether);
    }
}

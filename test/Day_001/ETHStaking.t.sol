//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {ETHStaking} from "src/Day_001/ETHStaking.sol";

contract ETHStakingTest is Test {
    ETHStaking public stakingContract;

    receive() external payable {}

    function setUp() public {
        stakingContract = new ETHStaking();
    }

    function testStake() public {
        uint256 stakeAmount = 0.2 ether;
        vm.deal(address(this), stakeAmount);
        stakingContract.stake{value: stakeAmount}(stakeAmount);
        assertEq(stakingContract.balances(address(this)), stakeAmount);
    }

    function testWithdraw() public {
        uint256 stakeAmount = 0.2 ether;
        vm.deal(address(this), stakeAmount);
        stakingContract.stake{value: stakeAmount}(stakeAmount);

        // Fast forward to after lockup period
        vm.warp(block.timestamp + 7 days);

        stakingContract.withdraw(stakeAmount);
        assertEq(stakingContract.balances(address(this)), 0);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "src/Day_011/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;

    function setUp() public {
        myToken = new MyToken();
    }

    function testOWnerCanMint() public {
        myToken.mint(address(1), 6);
    }

    function test_Revert_When_NotOwner() public {
        vm.expectRevert(MyToken.MyToken__NotOwner.selector);
        vm.prank(address(1));
        myToken.mint(address(1), 6);
    }

    function testBalanceUpdate() public {
        address user = address(1);
        myToken.mint(user, 100);
        uint256 balance = myToken.balanceOf(user);
        assertEq(balance, 100);
    }

    function testTransferAndReceive() public {
        address damola = address(this);
        address tunde = address(2);
        myToken.mint(damola, 200);
        myToken.transfer(tunde, 100);
        uint256 balanceOwner = myToken.balanceOf(damola);
        uint256 balanceReceiver = myToken.balanceOf(tunde);
        assertEq(balanceOwner, 100);
        assertEq(balanceReceiver, 100);
    }

    function testTotalSupplyUpdate() public {
        myToken.mint(address(this), 1000);
        myToken.mint(address(this), 1000);
        uint256 totalSupply = myToken.totalSupply();
        assertEq(totalSupply, 2000);
    }

    function testAllowances() public {
        address owner = address(this);
        address shadowUser = address(1);
        myToken.mint(address(this), 1000);
        myToken.approve(shadowUser, 200);
        uint256 allowance = myToken.allowance(owner, shadowUser);
        assertEq(allowance, 200);
    }

    function test_Revert_When_NotApproved() public {
        address damola = address(1);
        address tunde = address(2);
        address wale = address(3);
        myToken.mint(damola, 1000);
        vm.startPrank(damola);
        myToken.approve(tunde, 200);
        vm.stopPrank();
        vm.expectRevert(MyToken.MyToken__NotApprovedForThisAmount.selector);
        vm.startPrank(tunde);
        myToken.transferFrom(damola, wale, 300);
        vm.stopPrank();
    }

    function test_Revert_When_Its_Zero_Address() public {
        vm.expectRevert(MyToken.MyToken__CantBeZeroAddress.selector);
        myToken.mint(address(0), 100);
    }

    function testCanMintWhenNotAddressZero() public {
        myToken.mint(address(1), 100);
    }

    function testSpenderCantBeZeroAddress() public {
        myToken.mint(address(1), 200);
        vm.startPrank(address(1));
        myToken.transfer(address(0), 100);
        vm.stopPrank();
        vm.startPrank(address(0));
        myToken.approve(address(this), 100);
        vm.stopPrank();
        vm.expectRevert(MyToken.MyToken__CantBeZeroAddress.selector);
        myToken.transferFrom(address(0), address(1), 100);
    }

    function testReceiverCantBeZeroAddressInTransferFrom() public {
        myToken.mint(address(1), 200);
        vm.startPrank(address(1));
        myToken.transfer(address(2), 100);
        vm.stopPrank();
        vm.startPrank(address(2));
        myToken.approve(address(this), 100);
        vm.stopPrank();
        vm.expectRevert(MyToken.MyToken__CantBeZeroAddress.selector);
        myToken.transferFrom(address(2), address(0), 100);
    }

    function testTransferFromWhenSpenderIsApproved() public {
        address damola = address(1);
        address tunde = address(2);
        address wale = address(3);
        myToken.mint(damola, 1000);
        vm.startPrank(damola);
        myToken.approve(tunde, 200);
        vm.stopPrank();
        vm.startPrank(tunde);
        myToken.transferFrom(damola, wale, 200);
        vm.stopPrank();
    }
}

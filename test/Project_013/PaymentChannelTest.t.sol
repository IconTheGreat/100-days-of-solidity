//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SimplePaymentChannel} from "../../src/Project_013/SimplePaymentChannel.sol";

contract PaymentChannelTest is Test {
    SimplePaymentChannel channel;
    address owner = address(0x123);
    address receiver = address(0x456);

    function setUp() public {
        channel = new SimplePaymentChannel(receiver, owner);
    }

    function testInitialBalance() public view {
        assertEq(address(channel).balance, 0);
    }

    function testOwner() public view {
        assertEq(channel.owner(), owner);
    }

    function testReceiver() public view {
        assertEq(channel.receiver(), receiver);
    }

    function testChannelNotOpenedInitially() public view {
        assertFalse(channel.getHasChannelOpened());
    }

    function testReceiverCannotBeZeroAddress() public {
        vm.expectRevert(SimplePaymentChannel.CantBeZeroAddress.selector);
        new SimplePaymentChannel(address(0), owner);
    }

    function testOwnerCannotBeZeroAddress() public {
        vm.expectRevert(SimplePaymentChannel.CantBeZeroAddress.selector);
        new SimplePaymentChannel(receiver, address(0));
    }
}

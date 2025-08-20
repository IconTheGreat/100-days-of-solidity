//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {SimplePaymentChannel} from "../../src/Project_013/SimplePaymentChannel.sol";
import {Test} from "forge-std/Test.sol";

contract PaymentChannelTest is Test {
    SimplePaymentChannel public channel;
    address owner = address(1);
    address receiver = address(2);

    function setUp() public {
        channel = new SimplePaymentChannel(receiver);
    }
}

//SPDX-License-Identifier: MIT

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

pragma solidity ^0.8.19;

contract SimplePaymentChannel is EIP712, ReentrancyGuard {
    using ECDSA for bytes32;

    error NotOwner(address);
    error NotReceiver(address);
    error CantBeZeroAddress();
    error AmountCantBeZero();
    error MustBeMoreThanZeroAmount();
    error NonceUSed();
    error InvalidSignature();
    error InsufficientChannelBalance();
    error TxFailed();
    error ChannelStillOpened();
    error FundsStillInContract();
    error ChannelDeadlineHasNotMet();
    error ChannelDeadlineMet();

    address public immutable owner;
    address public immutable receiver;
    bool hasChannelOpened;
    uint256 public balance;
    uint256 public channelDeadline;
    mapping(uint256 => bool) public usedNonce;

    bytes32 private constant PAYMENT_TYPEHASH =
        keccak256("Payment(address channel,address receiver,uint256 amount,uint256 nonce)");

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }
        _;
    }

    modifier onlyReceiver() {
        if (msg.sender != receiver) {
            revert NotReceiver(msg.sender);
        }
        _;
    }

    constructor(address _receiver) EIP712("SimplePaymentChannel", "1") {
        if (_receiver == address(0)) {
            revert CantBeZeroAddress();
        }
        owner = msg.sender;
        receiver = _receiver;
    }

    function openChannel(uint256 _channelDeadline) public onlyOwner {
        channelDeadline = _channelDeadline;
        hasChannelOpened = true;
    }

    function deposit() external payable onlyOwner {
        if (msg.value == 0) {
            revert AmountCantBeZero();
        }
        balance += msg.value;
    }

    function verifyAndWithdraw(uint256 amount, uint256 nonce, bytes calldata signature)
        external
        nonReentrant
        onlyReceiver
    {
        if (amount == 0) revert MustBeMoreThanZeroAmount();
        if (usedNonce[nonce] == true) revert NonceUSed();
        if (block.timestamp > channelDeadline) revert ChannelDeadlineMet();

        bytes32 structHash = keccak256(abi.encode(PAYMENT_TYPEHASH, address(this), receiver, amount, nonce));

        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(digest, signature);
        if (signer != owner) revert InvalidSignature();
        usedNonce[nonce] = true;

        if (amount > balance) revert InsufficientChannelBalance();
        balance -= amount;
        (bool success,) = payable(receiver).call{value: amount}("");
        if (!success) revert TxFailed();
    }

    function closeChannel() public onlyReceiver nonReentrant {
        if (block.timestamp < channelDeadline) revert ChannelDeadlineHasNotMet();
        if (balance > 0) revert FundsStillInContract();
        hasChannelOpened = false;
    }

    function ownerWithdrawRemainder() public nonReentrant onlyOwner {
        if (block.timestamp < channelDeadline) revert ChannelDeadlineHasNotMet();
        if (!hasChannelOpened || channelDeadline > block.timestamp && balance > 0) {
            uint256 amt = balance;
            balance = 0;
            (bool success,) = payable(owner).call{value: amt}("");
            if (!success) revert TxFailed();
        } else {
            revert ChannelStillOpened();
        }
    }
}

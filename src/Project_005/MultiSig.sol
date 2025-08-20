//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

contract multiSigWallet {
    error NotEnoughApprovals(uint256 required, uint256 current);
    error AlreadyExecuted();
    error AlreadyApproved();
    error InvalidRecipient();
    error NotAnOwner();
    error OwnerDuplicated();
    error OwnerCantBeZero();

    event TransactionSubmitted(address indexed sender, uint256 indexed txId, address to, uint256 amount);

    event TransactionExecuted(uint256 indexed txId, address to, uint256 amount);
    event TransactionApproved(uint256 indexed txId, address indexed owner);

    uint256 requiredApprovals = 2;
    uint256 txIdCounter;
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public hasApproved;
    mapping(address => bool) public isOwner;
    address[3] public owners;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) {
            revert NotAnOwner();
        }
        _;
    }

    struct Transaction {
        address to;
        uint256 amount;
        bool executed;
        uint256 approvals;
    }

    constructor(address[3] memory _owners) {
        for (uint256 i = 0; i < 3; i++) {
            address owner = _owners[i];
            if (owner == address(0)) {
                revert OwnerCantBeZero();
            }
            if (isOwner[owner]) {
                revert OwnerDuplicated();
            }

            isOwner[owner] = true;
            owners[i] = owner;
        }
    }

    function submitTransaction(address to, uint256 amount) external onlyOwner {
        uint256 txId = txIdCounter;
        transactions[txId] = Transaction({to: to, amount: amount, executed: false, approvals: 0});

        txIdCounter += 1;

        emit TransactionSubmitted(msg.sender, txId, to, amount);
    }

    function approveTransaction(uint256 txId) external onlyOwner {
        Transaction storage txn = transactions[txId];
        if (hasApproved[txId][msg.sender]) {
            revert AlreadyApproved();
        }

        if (txn.to == address(0)) {
            revert InvalidRecipient();
        }

        if (txn.executed) {
            revert AlreadyExecuted();
        }

        hasApproved[txId][msg.sender] = true;
        txn.approvals += 1;
        emit TransactionApproved(txId, msg.sender);
    }

    function executeTransaction(uint256 txId) external onlyOwner {
        Transaction storage txn = transactions[txId];
        if (txn.executed) {
            revert AlreadyExecuted();
        }

        if (txn.approvals < requiredApprovals) {
            revert NotEnoughApprovals(requiredApprovals, txn.approvals);
        }

        if (txn.to == address(0)) {
            revert InvalidRecipient();
        }

        txn.executed = true;

        (bool success,) = payable(txn.to).call{value: txn.amount}("");
        require(success, "Transfer failed");

        emit TransactionExecuted(txId, txn.to, txn.amount);
    }

    receive() external payable {}
}

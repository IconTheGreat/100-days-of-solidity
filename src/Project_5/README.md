# 📝 MultiSig Wallet

This is a **simple MultiSig Wallet smart contract** written in Solidity.  
It allows **3 owners** to collectively manage funds and approve transactions.  
A transaction requires **2 approvals** before it can be executed.

---

## Features

✅ **Submit Transaction**  
Any owner can propose a transaction specifying:
- The recipient address (`to`)
- The amount of Ether to send

✅ **Approve Transaction**  
Owners can approve a pending transaction.  
Each owner can only approve once.

✅ **Execute Transaction**  
Once **2 approvals** are collected, any owner can execute the transaction, transferring the funds.

✅ **Receive Ether**  
The contract can receive Ether deposits.

✅ **Custom Errors**
- `NotEnoughApprovals`: Not enough approvals to execute.
- `AlreadyExecuted`: Transaction already executed.
- `AlreadyApproved`: Approval already given by this owner.
- `InvalidRecipient`: Recipient address is zero.
- `NotAnOwner`: Caller is not an owner.
- `OwnerDuplicated`: Duplicate owner address in constructor.
- `OwnerCantBeZero`: Owner address cannot be zero.

---

##  Contract Overview

| Element               | Description                                     |
|------------------------|-------------------------------------------------|
| **Owners**            | 3 addresses specified at deployment             |
| **Required Approvals**| 2                                               |
| **Mappings**          | Track approvals and transaction status          |
| **Structs**           | `Transaction` struct to store transaction data  |
| **Events**            | Transaction lifecycle events (`Submitted`, `Approved`, `Executed`) |

---

##  Functions

### `constructor(address[3] memory _owners)`
Initializes the wallet with 3 owner addresses.

### `submitTransaction(address to, uint256 amount)`
Creates a new transaction proposal.

### `approveTransaction(uint txId)`
Approves a transaction by transaction ID.

### `executeTransaction(uint txId)`
Executes a transaction if enough approvals are collected.

### `receive() external payable`
Allows the contract to receive Ether.

---

##  Example Workflow

1. **Deploy** the contract with 3 owner addresses.
2. **Deposit Ether** into the contract.
3. An owner **submits a transaction** specifying the recipient and amount.
4. Other owners **approve the transaction**.
5. Once approved by at least 2 owners, any owner **executes the transaction**.

---

##  Security Notes

- Each transaction can only be executed once.
- Each owner can approve a transaction only once.
- Transactions to the zero address are rejected.

---

##  License

MIT

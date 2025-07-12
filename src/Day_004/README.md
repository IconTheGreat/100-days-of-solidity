# 🐷 Piggy Bank Smart Contract

A simple Solidity smart contract that allows a group of members to deposit and withdraw Ether securely.

---

##  Features

✅ **Manager Role**
- The deployer becomes the contract manager.
- Only the manager can add new members.

✅ **Membership Control**
- Only members can deposit funds.
- Depositing automatically adds the sender as a member.

✅ **Deposits**
- Members can deposit Ether into their individual balance.

✅ **Withdrawals**
- Members can withdraw any amount up to their balance.

✅ **Events**
- `Deposit`: Emitted when a member deposits funds.
- `Withdraw`: Emitted when a member withdraws funds.

✅ **Custom Errors**
- `Insufficient`: Deposit or withdrawal amount is zero.
- `NotAMember`: Caller is not a registered member.
- `ZeroBalance`: Attempt to withdraw with zero balance.
- `NotEnoughBalance`: Withdrawal exceeds available balance.

---

##  Contract Overview

| Element               | Description                              |
|------------------------|------------------------------------------|
| **manager**           | Address of the contract manager          |
| **members**           | Array of all addresses that are members  |
| **balances**          | Mapping of member balances               |
| **isAMember**         | Mapping to track membership status       |

---

##  Functions

### `constructor()`
Initializes the contract. Sets the deployer as the manager and first member.

---

### `addMember(address _member)`
**Only Manager**
- Adds a new address to the members list.

---

### `deposit() external payable`
- Allows a member to deposit Ether.
- If the sender is not yet a member, they are added automatically.

---

### `withdraw(uint256 _amount) external`
- Withdraws Ether from the sender’s balance.
- Transfers Ether to the sender.

---

##  Usage Example

1. **Deploy** the contract.
2. The deployer is automatically the manager and a member.
3. The manager can **add members** via `addMember`.
4. Members can **deposit Ether**.
5. Members can **withdraw their balance** at any time.

---

##  Security Notes

- Only the manager can add members.
- Reverts if withdrawing more than balance.
- Uses `call` for Ether transfers with proper success checks.

---

##  License

MIT

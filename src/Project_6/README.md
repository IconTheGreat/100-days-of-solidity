# CreditProtocol

A Solidity smart contract for managing decentralized IOUs (I Owe You) between lenders and borrowers, with optional middleman dispute resolution.

---

## Overview

**CreditProtocol** enables:
- Creation of IOUs with predefined loan terms.
- Borrower acceptance of IOUs.
- Repayment into escrow.
- Dispute raising and resolution by a designated middleman.
- Final settlement and fund release.

---

## Features

- **Create IOUs**: Lender specifies borrower, middleman, amount, and interest.
- **Accept IOUs**: Borrower must accept before repayment.
- **Repayment Escrow**: Funds are held in contract escrow until released.
- **Dispute Resolution**: Either party can raise a dispute, which is adjudicated by the middleman.
- **Secure Withdrawals**: Non-reentrant release of funds to lender or borrower.

---

## Contract Details

### State Variables

- `owner`: Deployer of the contract.
- `IOU_ID_COUNTER`: Tracks the next IOU ID.
- `debts`: Mapping of IOU IDs to Debt records.
- `disputes`: Mapping of issues raised per IOU.
- `isALender`: Role mapping for lenders.
- `isABorrower`: Role mapping for borrowers.
- `isMiddleman`: Role mapping for middlemen.
- `hasAccept`: Flags whether an IOU has been accepted.
- `debtExists`: Flags whether an IOU exists.
- `IOUs`: Array of all IOU IDs.

---

### Structs

#### Debt

- `lender`: Address of the lender.
- `borrower`: Address of the borrower.
- `middleman`: Address of the middleman.
- `amount`: Principal amount.
- `interestRate`: Interest rate applied.
- `totalLoanWithInterest`: Total repayment amount.
- `escrowedAmount`: Funds held in escrow.
- `note`: Descriptive note.
- `accepted`: Flag indicating borrower acceptance.
- `cleared`: Flag indicating repayment has been made.
- `ended`: Flag indicating the IOU is finalized.

---

## Main Functions

### createIOU
Creates a new IOU agreement.
```
function createIOU(
    address lender,
    address borrower,
    address middleman,
    uint256 amount,
    uint256 interestRate,
    uint256 totalLoanWithInterest,
    string memory note
) public
```

### acceptIOU
Borrower accepts the IOU terms.
```
function acceptIOU(
    uint256 IOU_ID,
    string memory note
) public onlyBorrower
```

### repayIOU
Borrower repays the loan into escrow.
```
function repayIOU(uint256 IOU_ID) external payable onlyBorrower
```

### raiseDispute
Lender or borrower raises a dispute.
```
function raiseDispute(
    uint256 IOU_ID,
    string memory issue
) public onlyLenderOrBorrower
```

### addressDispute
Middleman resolves the dispute.
```
function addressDispute(
    uint256 IOU_ID,
    bool borrowerWins
) public onlyMiddleman nonReentrant
```

### releaseToLender
Lender withdraws escrowed funds.
```
function releaseToLender(uint256 IOU_ID) external onlyLender nonReentrant
```

### endIOU
Lender ends the IOU.
```
function endIOU(uint256 IOU_ID) public onlyLender
```

---

## Security

- Uses `ReentrancyGuard` to prevent reentrancy attacks during fund transfers.
- Validates role permissions with modifiers.
- Requires exact repayment amounts.

---

## Events

- `IOUCreate`: Emitted on creation.
- `IOUAccept`: Emitted when borrower accepts.
- `debtCleared`: Emitted on repayment.
- `IOUEnded`: Emitted when an IOU is finalized.

---

## License

MIT

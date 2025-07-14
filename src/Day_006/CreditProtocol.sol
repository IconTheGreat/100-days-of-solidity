//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CreditProtocol is ReentrancyGuard {
    //errors
    error NotALender();
    error NotABorrower();
    error NotLenderOrBorrower();
    error NotAMiddleman();
    error AlreadyAccepted();
    error InvalidIOU();
    error InvalidAmount();
    error AlreadyPaid();
    error AcceptBeforeRepay();
    error EmptyIssue();
    error debtAlreadyClearedAndEnded();

    //events
    event IOUCreate(
        address indexed creator,
        uint256 IUO_ID,
        uint256 amount,
        address borrower,
        uint256 interestRate
    );

    event IOUAccept(uint256 IOU_ID, address borrower, string note);
    event IOUDispute();
    event debtCleared(
        uint256 IOU_ID,
        address lender,
        address borrower,
        string note
    );
    event IOUEnded(
        uint256 IOU_ID,
        address lender,
        address borrower,
        string note
    );

    //state variables
    address public owner;
    uint256 public IOU_ID_COUNTER;
    mapping(uint256 => Debt) public debts;
    mapping(uint256 => mapping(address => string)) public disputes;
    mapping(uint256 => mapping(address => bool)) public isALender;
    mapping(uint256 => mapping(address => bool)) public isABorrower;
    mapping(uint256 => mapping(address => bool)) public isMiddleman;
    mapping(uint256 => bool) public hasAccept;
    mapping(uint256 => bool) public debtExists;
    uint256[] public IOUs;

    //modifiers
    modifier onlyLender(uint256 IOU_ID) {
        if (!isALender[IOU_ID][msg.sender]) {
            revert NotALender();
        }
        _;
    }

    modifier onlyBorrower(uint256 IOU_ID) {
        if (!isABorrower[IOU_ID][msg.sender]) {
            revert NotABorrower();
        }
        _;
    }

    modifier onlyLenderOrBorrower(uint256 IOU_ID) {
        if (
            !isABorrower[IOU_ID][msg.sender] && !isALender[IOU_ID][msg.sender]
        ) {
            revert NotLenderOrBorrower();
        }
        _;
    }

    modifier onlyMiddleman(uint256 IOU_ID) {
        if (!isMiddleman[IOU_ID][msg.sender]) {
            revert NotAMiddleman();
        }
        _;
    }

    //struct

    struct Debt {
        address lender;
        address borrower;
        address middleman;
        uint256 amount;
        uint256 interestRate;
        uint256 totalLoanWithInterest;
        uint256 escrowedAmount;
        string note;
        bool accepted;
        bool cleared;
        bool ended;
    }

    //constructor
    constructor() {
        owner = msg.sender;
    }

    //functions
    function createIOU(
        address lender,
        address borrower,
        address middleman,
        uint256 amount,
        uint256 interestRate,
        uint256 totalLoanWithInterest,
        string memory note
    ) public {
        uint256 IOU_ID = IOU_ID_COUNTER;
        debts[IOU_ID] = Debt({
            lender: lender,
            borrower: borrower,
            middleman: middleman,
            amount: amount,
            interestRate: interestRate,
            totalLoanWithInterest: totalLoanWithInterest,
            escrowedAmount: 0,
            note: note,
            accepted: false,
            cleared: false,
            ended: false
        });

        IOU_ID_COUNTER += 1;
        isALender[IOU_ID][lender] = true;
        isABorrower[IOU_ID][borrower] = true;
        debtExists[IOU_ID] = true;
        IOUs.push(IOU_ID);

        emit IOUCreate(msg.sender, IOU_ID, amount, borrower, interestRate);
    }

    function acceptIOU(
        uint256 IOU_ID,
        string memory note
    ) public onlyBorrower(IOU_ID) {
        Debt storage IOU = debts[IOU_ID];
        if (hasAccept[IOU_ID]) {
            revert AlreadyAccepted();
        }

        if (!debtExists[IOU_ID]) {
            revert InvalidIOU();
        }

        IOU.accepted = true;
        hasAccept[IOU_ID] = true;
        IOU.note = note;
        emit IOUAccept(IOU_ID, msg.sender, IOU.note);
    }

    function repayIOU(uint256 IOU_ID) external payable onlyBorrower(IOU_ID) {
        Debt storage IOU = debts[IOU_ID];
        require(
            msg.value == IOU.totalLoanWithInterest,
            "Pls pay full plus the agreed interest"
        );
        if (msg.value <= 0) {
            revert InvalidAmount();
        }
        if (IOU.accepted == false) {
            revert AcceptBeforeRepay();
        }
        if (IOU.cleared == true) {
            revert AlreadyPaid();
        }

        IOU.cleared = true;
        IOU.escrowedAmount = msg.value;
        emit debtCleared(IOU_ID, IOU.lender, IOU.borrower, IOU.note);
    }

    function raiseDispute(
        uint256 IOU_ID,
        string memory issue
    ) public onlyLenderOrBorrower(IOU_ID) {
        Debt storage IOU = debts[IOU_ID];
        if (bytes(issue).length == 0) {
            revert EmptyIssue();
        }
        if (IOU.ended == true) {
            revert debtAlreadyClearedAndEnded();
        }

        disputes[IOU_ID][msg.sender] = issue;
    }

    function addressDispute(
        uint256 IOU_ID,
        bool borrowerWins
    ) public onlyMiddleman(IOU_ID) nonReentrant {
        Debt storage IOU = debts[IOU_ID];
        require(IOU.escrowedAmount > 0, "No escrowed funds");

        uint256 amount = IOU.escrowedAmount;
        IOU.escrowedAmount = 0;
        IOU.ended = true;

        address recipient = borrowerWins ? IOU.borrower : IOU.lender;

        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Transfer failed");
        IOU.ended = true;
    }

    function releaseToLender(
        uint256 IOU_ID
    ) external onlyLender(IOU_ID) nonReentrant {
        Debt storage IOU = debts[IOU_ID];
        require(IOU.cleared == true, "Not paid yet");
        require(IOU.escrowedAmount > 0, "Not escrowed funds");
        uint256 amount = IOU.escrowedAmount;
        IOU.escrowedAmount = 0;
        (bool success, ) = payable(IOU.lender).call{value: amount}("");
        require(success, "Transfer failed");
        IOU.ended = true;
    }

    function endIOU(uint256 IOU_ID) public onlyLender(IOU_ID) {
        Debt storage IOU = debts[IOU_ID];
        require(msg.sender == IOU.lender, "Only lender can end");
        require(IOU_ID != 0, "You cant end an IOU with zero ID");

        IOU.ended = true;

        emit IOUEnded(IOU_ID, IOU.lender, IOU.borrower, IOU.note);
    }
}

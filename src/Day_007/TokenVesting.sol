// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVestingContract {
    // Errors
    error MustBeBeneficiary();
    error NotYetTime();
    error MustBeInFuture();

    //events
    event VestingCreated(uint256 vestId, address beneficiary, uint256 totalAmount);
    event TokensReleased(uint256 vestId, uint256 milestoneIndex, uint256 amount);

    // State variables
    uint256 public vestIdCounter;
    IERC20 public token;
    address public owner;
    mapping(uint256 => Vest) public vestings;

    // Structs
    struct VestingMilestone {
        uint256 timestamp;
        uint256 amount;
        bool released; // NEW: Track if this milestone is already claimed
    }

    struct Vest {
        address beneficiary;
        uint256 totalAmount;
        uint256 releasedAmount;
        VestingMilestone[] cliff;
    }

    // Modifiers
    modifier onlyBeneficiary(uint256 vestId) {
        Vest storage vest = vestings[vestId];
        require(msg.sender == vest.beneficiary, "Can't release token");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Constructor
    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    // Functions

    function addVestingSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 releasedAmount,
        VestingMilestone[] memory cliffs
    ) public onlyOwner {
        uint256 vestId = vestIdCounter;
        vestIdCounter++;

        Vest storage v = vestings[vestId];
        v.beneficiary = beneficiary;
        v.totalAmount = totalAmount;
        v.releasedAmount = releasedAmount;

        // Instead of direct assignment, copy each milestone
        for (uint256 i = 0; i < cliffs.length; i++) {
            v.cliff.push(cliffs[i]);
        }
        emit VestingCreated(vestId, beneficiary, totalAmount);
    }

    function releaseToken(uint256 vestId) public onlyBeneficiary(vestId) {
        Vest storage vest = vestings[vestId];
        bool anyReleased = false;

        for (uint256 i = 0; i < vest.cliff.length; i++) {
            VestingMilestone storage milestone = vest.cliff[i];
            require(vest.cliff[i].amount > 0, "No tokens to release");
            if (block.timestamp >= milestone.timestamp && !milestone.released) {
                // Mark this milestone as released
                milestone.released = true;

                // Update vesting state
                vest.releasedAmount += milestone.amount;

                // Transfer tokens
                bool success = token.transfer(vest.beneficiary, milestone.amount);
                require(success, "Transfer failed");

                anyReleased = true;
                emit TokensReleased(vestId, i, milestone.amount);
            } else {
                revert MustBeInFuture();
            }
        }

        if (!anyReleased) {
            revert NotYetTime();
        }
    }

    function getReleasableAmount(uint256 vestId) public view returns (uint256 total) {
        Vest storage vest = vestings[vestId];
        for (uint256 i = 0; i < vest.cliff.length; i++) {
            if (block.timestamp >= vest.cliff[i].timestamp && !vest.cliff[i].released) {
                total += vest.cliff[i].amount;
            }
        }
    }
}

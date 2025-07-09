//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ETHStaking {
    address public owner;
    uint256 public lockUpPeriod = 7 days;
    uint256 public stakingPeriod = 365 days;
    uint256 public minimumETH = 0.1 ether;
    uint256[] public totalStakedETH;
    address[] public stakers;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public stakeTime;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function stake(uint256 _ethAmount) public payable {
        require(_ethAmount > minimumETH, "can't stake lower than 0.1 ether");
        balances[msg.sender] += _ethAmount;
        stakers.push(msg.sender);
        totalStakedETH.push(_ethAmount);
        stakeTime[msg.sender] = block.timestamp;
    }

    function withdraw(uint256 _amount) external {
        bool hasStaked = false;

        // looping through the stakers array to get if the msg.sender is a staker
        for (uint256 i = 0; i < stakers.length; i++) {
            if (stakers[i] == msg.sender) {
                hasStaked = true;
                break;
            }
        }
        require(hasStaked == true, "You have not stake yet");
        require(
            block.timestamp >= stakeTime[msg.sender] + lockUpPeriod,
            "wait for 7 dyas after staking"
        );
        require(_amount <= balances[msg.sender], "insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function complete() external onlyOwner {
        require(block.timestamp >= stakingPeriod, "wait for 365 days");

        uint256 total;

        // looping through the array of total ether staked

        for (uint256 i = 0; i < totalStakedETH.length; i++) {
            total += totalStakedETH[i];
        }

        // reset total balance to avoid reentrancy
        total = 0;
        // transfer total to owner
        (bool success, ) = payable(msg.sender).call{value: total}("");
        require(success, "Transfer failed");
    }
}

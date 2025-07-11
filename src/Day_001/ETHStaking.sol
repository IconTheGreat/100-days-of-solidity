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
    mapping(address => bool) public isStaker;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    event Withdraw(address indexed user, uint256 amount);
    event Stake(address indexed user, uint256 amount);
    event Completed(uint256 total);

    function stake() public payable {
        require(msg.value >= minimumETH, "can't stake lower than 0.1 ether");
        balances[msg.sender] += msg.value;
        stakers.push(msg.sender);
        totalStakedETH.push(msg.value);
        stakeTime[msg.sender] = block.timestamp;
        isStaker[msg.sender] = true;

        emit Stake(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        require(balances[msg.sender] > 0, "You have no balance to withdraw");
        require(isStaker[msg.sender], "You have not staked yet");
        require(block.timestamp >= stakeTime[msg.sender] + lockUpPeriod, "wait for 7 days after staking");
        require(_amount <= balances[msg.sender], "insufficient balance");
        balances[msg.sender] -= _amount;
        totalStakedETH.push(_amount);
        if (balances[msg.sender] == 0) {
            isStaker[msg.sender] = false;
        }
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, _amount);
    }

    function complete() external onlyOwner {
        require(block.timestamp >= stakingPeriod, "wait for 365 days");

        uint256 total;

        // Loop over all stakers
        for (uint256 i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            total += balances[staker];
            balances[staker] = 0;
            isStaker[staker] = false;
        }

        delete stakers;
        delete totalStakedETH;

        (bool success,) = payable(msg.sender).call{value: total}("");
        require(success, "Transfer failed");

        emit Completed(total);
    }
}

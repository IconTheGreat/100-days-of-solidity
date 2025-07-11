//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

contract piggyBank {
    address public manager;
    address[] public members;
    mapping(address => uint256) public balances;
    mapping(address => bool) public isAMember;

    constructor() {
        manager = msg.sender;
        members.push(msg.sender);
        isAMember[manager] = true;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "only manager can call this funtion");
        _;
    }

    event Withdraw(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);

    //Errors

    error Insufficient();
    error NotAMember();
    error ZeroBalance();
    error NotEnoughBalance();

    function addMember(address _member) public onlyManager {
        require(isAMember[_member] == false, "Already a member");
        members.push(_member);
        isAMember[msg.sender] = true;
    }

    function deposit() external payable {
        if (msg.value <= 0) {
            revert Insufficient();
        }

        if (isAMember[msg.sender] == false) {
            revert NotAMember();
        }

        balances[msg.sender] += msg.value;
        members.push(msg.sender);
        isAMember[msg.sender] = true;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external payable {
        if (_amount <= 0) {
            revert Insufficient();
        }

        if (balances[msg.sender] == 0) {
            revert ZeroBalance();
        }

        if (balances[msg.sender] < _amount) {
            revert NotEnoughBalance();
        }

        balances[msg.sender] -= _amount;
        // transfer amount to msg.sender
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, _amount);
    }
}

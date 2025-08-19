//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title MyToken
 * @author ICON
 * @notice A simple ERC20 token implementation
 * @dev This contract allows minting, transferring, and approving tokens with custom errors for better clarity.
 */
contract MyToken {
    // Custom errors
    error MyToken__CantBeZeroAddress();
    error MyToken__NotOwner();
    error MyToken__LesserBalance();
    error MyToken__NotApprovedForThisAmount();

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // State variables
    address public immutable owner;
    string public constant name = "IconToken";
    string public constant symbol = "ICON";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) public balances;
    mapping(address owner => mapping(address spender => uint256 amount)) public approvals;

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert MyToken__NotOwner();
        }
        _;
    }

    // Functions

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        if (to == address(0)) {
            revert MyToken__CantBeZeroAddress();
        }
        balances[to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address receiver, uint256 amount) public returns (bool) {
        if (balances[msg.sender] < amount) {
            revert MyToken__LesserBalance();
        }
        balances[receiver] += amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function transferFrom(address sender, address receiver, uint256 amount) public returns (bool) {
        if (approvals[sender][msg.sender] < amount) {
            revert MyToken__NotApprovedForThisAmount();
        }
        if (balances[sender] < amount) {
            revert MyToken__LesserBalance();
        }
        if (sender == address(0) || receiver == address(0)) {
            revert MyToken__CantBeZeroAddress();
        }
        balances[sender] -= amount;
        balances[receiver] += amount;
        approvals[sender][msg.sender] -= amount;
        emit Transfer(sender, receiver, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        approvals[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address user) public view returns (uint256) {
        return balances[user];
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return approvals[_owner][spender];
    }
}

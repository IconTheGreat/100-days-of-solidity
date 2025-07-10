//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TreasureHunt {
    address public owner;
    uint256 public startTime;
    uint256 public huntDuration = 7 days;

    bytes32 public secretHash;
    bool isOpened = false;
    mapping(address => bool) public hasGuessed;
    mapping(address => string[]) public allHints;

    constructor(uint256 treasure, string memory _secretPhrase) payable {
        owner = msg.sender;
        require(treasure > 0, "treasure must be greater than 0");
        require(msg.value == treasure, "msg.value must equal _treasure");
        require(
            bytes(_secretPhrase).length > 0,
            "Secret phrase cannot be empty"
        );
        secretHash = keccak256(abi.encodePacked(_secretPhrase));
        startTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function openChest(string memory guess) external {
        require(!isOpened, "Chest already opened");
        bytes32 guessHash = keccak256(abi.encodePacked(guess));
        require(guessHash == secretHash, "wrong! guess not matched");

        isOpened = true;
        hasGuessed[msg.sender] = true;
        uint256 payout = address(this).balance;

        (bool success, ) = payable(msg.sender).call{value: payout}("");
        require(success, "Transfer failed");
    }

    function getHints(address index) public view returns (string[] memory) {
        return allHints[index];
    }

    function setHint(string memory hint) public onlyOwner {
        allHints[msg.sender].push(hint);
    }

    function reclaimTreasure() external onlyOwner {
        require(
            block.timestamp >= startTime + huntDuration,
            "Hunt hasn't ended yet!"
        );
        require(!isOpened, "Treasure already claimed");

        uint256 payout = address(this).balance;

        (bool success, ) = payable(msg.sender).call{value: payout}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}

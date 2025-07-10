//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

contract AuctionHouse {
    uint256 public auctionStartTime;
    uint256 public auctionEndTime = 7 days;
    uint256 public minimumBid = 0.1 ether;
    uint256 public highestBid;
    address private highestBidder;
    string public item;
    address public immutable owner;
    address[] public bidders;
    bool public settled = false;
    mapping(address => uint256) public bidAmount;

    constructor(string memory _item) {
        owner = msg.sender;
        item = _item;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function startAuction() public onlyOwner {
        auctionStartTime = block.timestamp;
    }

    function bid(uint256 _amount) external payable {
        require(settled = false, "Bid settled");
        require(_amount > minimumBid, "Minimum bid is 0.1 ether");
        bidAmount[msg.sender] += _amount;
        bidders.push(msg.sender);
    }

    function pickWinner() public onlyOwner {
        require(block.timestamp >= auctionEndTime, "Wait for 7days");

        uint256 max = 0;
        address winner;
        for (uint i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            uint256 _bid = bidAmount[bidder];

            if (_bid > max) {
                max = _bid;
                winner = bidder;
            }
        }

        highestBid = max;
        highestBidder = winner;
    }

    function EndAuction() public onlyOwner {
        require(block.timestamp >= auctionEndTime, "Wait for 7days");
        settled = true;
    }

    function withdraw() external {
        uint256 amount = bidAmount[msg.sender];
        require(!settled, "Auction has not yet ended");
        require(msg.sender != highestBidder, "Highest bidders cant withdraw");
        require(amount > 0, "no amount to withdraw yet");
        bool hasEntered = false;
        for (uint256 i = 0; i < bidders.length; i++) {
            if (bidders[i] == msg.sender) {
                hasEntered = true;
                break;
            }
        }
        require(hasEntered = true, "You are not a bidder!");

        // reset user bid amount to avoid reentrancy
        bidAmount[msg.sender] = 0;

        // transefer amount to msg.sender
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getAllBidders() public view returns (address[] memory) {
        return bidders;
    }
}

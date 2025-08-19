//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./MyNFT.sol";

contract DutchAuction {
    // errors
    error NOT_SELLER();
    error alreadyStarted();
    error auctionEnded();
    error sendExactPrice();

    // events
    event StartsAuction();
    event EndsAuction(address winner, uint256 price);

    // state variables
    IERC721 public nft;
    uint256 public tokenId;
    address public seller;
    uint256 public startTime;
    uint256 public duration;
    uint256 public startingPrice;
    uint256 public minimumPrice;
    uint256 public priceDropRate;
    bool public auctionEnds;

    // constructor
    constructor(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _SP,
        uint256 _minimumPrice,
        uint256 _priceDropRate
    ) {
        seller = msg.sender;
        duration = _duration;
        startingPrice = _SP;
        minimumPrice = _minimumPrice;
        priceDropRate = _priceDropRate;
        tokenId = _tokenId;
        nft = _nft;
    }

    // modifier
    modifier onlySeller() {
        if (msg.sender != seller) {
            revert NOT_SELLER();
        }
        _;
    }

    function depositNFT() external onlySeller {
        nft.transferFrom(msg.sender, address(this), tokenId);
    }

    function startAuction() public onlySeller {
        require(nft.ownerOf(tokenId) == address(this), "NFT not deposited");
        require(startingPrice > minimumPrice, "Starting price must be greater than minimum price");
        require(priceDropRate > 0, "Price drop rate must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");
        require(auctionEnds == false, "Auction already ended");
        if (startTime != 0) {
            revert alreadyStarted();
        }
        startTime = block.timestamp;
        emit StartsAuction();
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a >= b ? a : b);
    }

    function getCurrentPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startTime;
        uint256 calculatedPrice = startingPrice - (timeElapsed * priceDropRate);
        uint256 currentPrice = max(calculatedPrice, minimumPrice);
        return (currentPrice);
    }

    function buy() public payable {
        if (block.timestamp > startTime + duration) {
            revert auctionEnded();
        }

        if (msg.value == getCurrentPrice()) {
            IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
            (bool sent,) = payable(seller).call{value: msg.value}("");
            require(sent, "Failed to send Ether");
            startTime = 0;
            emit EndsAuction(msg.sender, msg.value);
            auctionEnds = true;
        } else {
            revert sendExactPrice();
        }
    }

    function endAuction() public onlySeller {
        require(startTime != 0, "Auction not started");

        require(block.timestamp > startTime + duration, "you can't end auction yet");
        nft.transferFrom(address(this), seller, tokenId);
        emit EndsAuction(msg.sender, 0);
        startTime = 0;
        auctionEnds = true;
    }
}

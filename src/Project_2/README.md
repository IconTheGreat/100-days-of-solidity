# AuctionHouse Contract

A basic Solidity auction contract for bidding on a single item.

## Features

- The owner starts an auction for an item.
- Users can place bids above a minimum amount.
- Bidders can withdraw their bids if they are not the highest bidder.
- The auction can be ended and settled by the owner.

## Functions

- `startAuction()`: Starts the auction timer.
- `bid(uint256 _amount)`: Place a bid (must exceed 0.1 ETH).
- `withdraw()`: Withdraw bid if not the winning bidder.
- `EndAuction()`: Ends the auction and marks it settled.
- `pickWinner()`: (To be implemented) Selects the highest bidder.
- `getAllBidders()`: Returns the list of all bidders.

## Notes

- Auction duration defaults to 7 days.
- The `item` name is set during deployment.
- Only the contract owner can start or end the auction.

## Usage

Deploy the contract with the item name, start the auction, allow bidding, then end and settle the auction.

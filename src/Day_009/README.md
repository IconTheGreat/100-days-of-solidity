# Dutch Auction NFT

This project contains two smart contracts:

- **MyNFT**: A simple ERC721 NFT contract.
- **DutchAuction**: A contract implementing a Dutch auction mechanism for selling an NFT.

---

## Contracts

### MyNFT.sol

An ERC721 NFT with a minting function restricted to the contract owner.

**Key Features:**
- `mint(address to)`: Mints a new NFT to the specified address.
- Token IDs increment automatically.

---

### DutchAuction.sol

A Dutch auction contract that allows a seller to auction an NFT with a decreasing price over time.

**Workflow:**
1. **Deploy MyNFT** and mint a token.
2. **Deploy DutchAuction** specifying:
   - NFT contract address
   - Token ID
   - Duration
   - Starting price
   - Minimum price
   - Price drop rate per second
3. **Deposit NFT** into the auction contract.
4. **Start the auction**.
5. Buyers can purchase the NFT by sending the exact current price.
6. The auction ends automatically on purchase or can be ended manually after the duration.

---

## Functions Overview

### MyNFT

- `mint(address to)`: Mints an NFT to `to`.

### DutchAuction

- `depositNFT()`: Seller deposits the NFT.
- `startAuction()`: Starts the auction timer.
- `getCurrentPrice()`: Returns the current price.
- `buy()`: Buys the NFT at the current price.
- `endAuction()`: Ends the auction if the duration has elapsed.

---

## Deployment Notes

- The auction contract must hold the NFT before starting the auction.
- Only the seller can start and end the auction.
- Buyers must send the exact price returned by `getCurrentPrice()`.

---

## License

MIT

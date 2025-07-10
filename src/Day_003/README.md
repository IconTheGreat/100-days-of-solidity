# 📜 TreasureHunt Smart Contract

A Solidity smart contract for creating time-limited treasure hunts with hidden phrases and ETH rewards. Players who correctly guess the secret phrase can claim the treasure.

---

## Features

- **Secret Phrase Validation:**  
  The owner sets a secret phrase hashed with Keccak256.
- **Time-Limited Hunts:**  
  The hunt lasts for a fixed duration (default: 7 days).
- **Treasure Payout:**  
  The first player to guess correctly receives the entire contract balance.
- **Hint Management:**  
  The owner can store and share hints with players.
- **Reentrancy Protection:**  
  Critical functions are protected using OpenZeppelin's `ReentrancyGuard`.
- **Treasure Reclaim:**  
  If the treasure remains unclaimed after the hunt period, the owner can reclaim it.

---

## Deployment

Make sure you are using Solidity version ^0.8.19.

### Constructor

```
constructor(uint256 _treasure, string memory _secretPhrase) payable
```

### Example

Deploy the contract with 1 Ether as the treasure:

```
new TreasureHunt{value: 1 ether}(1 ether, "your secret phrase, e.g "boy");
```

Note: `msg.value` must equal `_treasure`.

---

## Functions

### openChest(string memory guess)

Allows a player to attempt claiming the treasure by providing a guess of the secret phrase.

- Requires the chest to be unopened.
- If the guess is correct, transfers the entire contract balance to the caller.
- Marks the treasure as claimed.

---

### setHint(address player, string memory hint)

Allows the contract owner to add a hint associated with a specific player address.

---

### getHints(address player) view returns (string[] memory)

Retrieves the list of hints assigned to a player.

---

### reclaimTreasure()

Allows the contract owner to reclaim any unclaimed treasure after the hunt duration has passed.

---

## Security Considerations

- The contract uses the Checks-Effects-Interactions pattern to mitigate reentrancy risks.
- The owner can only reclaim the treasure if the hunt has expired and the chest has not been opened.
- All critical state updates are performed before transferring Ether.

---

## License

MIT License

---

## Testing

Before deploying to the Ethereum mainnet, thoroughly test the contract on a testnet such as Sepolia or Goerli to ensure expected behavior.
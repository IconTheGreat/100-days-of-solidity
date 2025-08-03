# Confessions 🕵️

A simple smart contract to submit and view anonymous confessions.

## Features
- Submit a secret (`submitConfession`)
- View a specific confession (`getConfession`)
- View all confessions (`getAllConfessions`)
- Emits `NewConfession` event on submission

Empty confessions are rejected with a custom error.

```solidity
confessions.submitConfession("I love Solidity.");
```

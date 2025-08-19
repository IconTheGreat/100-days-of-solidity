# ETH Staking Contract

A simple Solidity contract that allows users to stake ETH with a minimum amount and lock-up period.

## Features

- Users can stake at least 0.1 ETH.
- Staked ETH is locked for 7 days before withdrawal is allowed.
- Only the contract owner can finalize the staking period after 365 days.
- Tracks stakers, their balances, and staking timestamps.

## Functions

- `stake(uint256 _ethAmount)`: Stake ETH into the contract.
- `withdraw(uint256 _amount)`: Withdraw staked ETH after the lock-up period.
- `complete()`: Allows the owner to finalize staking after 365 days.

## Usage

Deploy the contract and interact with the functions to stake and withdraw ETH.

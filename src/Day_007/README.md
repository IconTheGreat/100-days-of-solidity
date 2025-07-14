# TokenVestingContract

This contract allows an ERC20 token to be gradually released to recipients over time according to a customizable vesting schedule.

## Overview

The contract owner can create vesting schedules for any beneficiary. Each schedule includes multiple milestones specifying:

- When tokens become available (timestamps)
- How many tokens unlock at each milestone

Once a milestone's time has passed, the beneficiary can claim their tokens. The contract keeps track of which milestones have been claimed to prevent double withdrawals.

## Main Features

- Only the contract owner is allowed to create vesting schedules.
- Each beneficiary can have a vesting schedule with one or more milestones.
- Each milestone defines a release date and amount.
- Beneficiaries can call a function to release any milestones that are unlocked.
- The contract emits events when schedules are created and when tokens are released.
- The contract prevents tokens from being claimed before the unlock date.
- The contract prevents milestones from being claimed more than once.

## Usage Flow

1. The contract is deployed with the address of the ERC20 token to vest.
2. The owner funds the contract with enough tokens to cover all planned vesting schedules.
3. The owner creates a vesting schedule for each beneficiary, defining the total amount and the milestone release dates and amounts.
4. After each milestone unlock date has passed, the beneficiary calls the release function to receive the unlocked tokens.
5. The contract records that each milestone has been released so it cannot be claimed again.

## Security Considerations

- Always check that the contract holds enough tokens to fulfill all vesting schedules.
- Review milestone definitions carefully to ensure the timestamps and amounts are correct.
- Test the contract thoroughly before deploying with real funds.
- Monitor emitted events to track when tokens are released.

## License

MIT

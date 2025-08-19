# SimpleCalculator

A Solidity smart contract implementing basic arithmetic operations for unsigned and signed integers.

## Functions

### Unsigned Operations (`uint256`)
- `add(uint256 a, uint256 b)` - Returns `a + b`
- `subtract(uint256 a, uint256 b)` - Returns `a - b`
- `multiply(uint256 a, uint256 b)` - Returns `a * b`
- `divide(uint256 a, uint256 b)` - Returns `a / b` (requires `b != 0`)
- `modulo(uint256 a, uint256 b)` - Returns `a % b`
- `power(uint256 base, uint256 exponent)` - Returns `base ^ exponent`

### Signed Operations (`int256`)
- `addInt(int256 a, int256 b)` - Returns `a + b`
- `subtractInt(int256 a, int256 b)` - Returns `a - b`
- `multiplyInt(int256 a, int256 b)` - Returns `a * b`
- `divideInt(int256 a, int256 b)` - Returns `a / b` (requires `b != 0`)
- `moduloInt(int256 a, int256 b)` - Returns `a % b`
- `powerInt(int256 base, uint256 exponent)` - Returns `base ^ exponent`

## License

MIT

# BTC-Stablecoin Bridge Smart Contract

A secure and efficient smart contract implementation for managing a Bitcoin-backed stablecoin on the Stacks blockchain. This contract enables users to create, manage, and trade stablecoins backed by Bitcoin collateral.

## Features

- **Collateralized Stablecoin Minting**: Create stablecoins backed by BTC collateral
- **Dynamic Price Oracle**: Maintained price feed for accurate collateral ratio calculations
- **Liquidity Pool Management**: Add and remove liquidity with automated market making
- **Vault Management**: Track and manage individual user vaults
- **Safety Mechanisms**: Built-in constraints and ratios to maintain system stability

## Key Parameters

- Minimum Collateral Ratio: 150%
- Liquidation Ratio: 130%
- Minimum Deposit: 0.01 BTC (1,000,000 sats)
- Pool Fee Rate: 0.3%
- Price Precision: 6 decimal places

## Functions

### Core Functions

1. **Initialization**
   - `initialize`: Set up the contract with initial price
   - `update-price`: Update the BTC/USD price oracle

2. **Vault Operations**
   - `deposit-collateral`: Lock BTC as collateral
   - `mint-stablecoin`: Create new stablecoins against collateral
   - `burn-stablecoin`: Burn stablecoins to reduce debt

3. **Liquidity Operations**
   - `add-liquidity`: Provide liquidity to the pool
   - `remove-liquidity`: Withdraw liquidity from the pool

### Read-Only Functions

- `get-vault-details`: View vault information
- `get-collateral-ratio`: Check current collateral ratio
- `get-pool-details`: View pool statistics
- `get-lp-details`: View liquidity provider information

## Error Codes

| Code | Description |
|------|-------------|
| 1000 | Not authorized |
| 1001 | Insufficient balance |
| 1002 | Invalid amount |
| 1003 | Insufficient collateral |
| 1004 | Pool empty |
| 1005 | Slippage too high |
| 1006 | Below minimum |
| 1007 | Above maximum |
| 1008 | Already initialized |
| 1009 | Not initialized |
| 1010 | Invalid price |

## Getting Started

1. Deploy the contract to the Stacks blockchain
2. Initialize with a valid BTC/USD price
3. Users can then:
   - Deposit BTC collateral
   - Mint stablecoins
   - Provide liquidity
   - Trade in the pool

## Security Considerations

- Maintains minimum collateral ratio of 150%
- Implements strict input validation
- Includes balance and overflow checks
- Uses safe arithmetic operations

## Development

This contract is written in Clarity, the smart contract language for the Stacks blockchain.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Security

For security concerns, please review our [SECURITY.md](SECURITY.md) file.
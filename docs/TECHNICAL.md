# Technical Documentation

## Contract Architecture

### Core Components

1. **Vault System**

   - Tracks user collateral
   - Manages stablecoin minting
   - Monitors collateral ratios

2. **Price Oracle**

   - Updates BTC/USD price
   - Validates price ranges
   - Ensures price accuracy

3. **Liquidity Pool**
   - Manages liquidity provision
   - Handles token swaps
   - Tracks LP tokens

### Data Structures

1. **Vaults**

```clarity
{
    btc-locked: uint,
    stablecoin-minted: uint,
    last-update-height: uint
}
```

2. **Liquidity Providers**

```clarity
{
    pool-tokens: uint,
    btc-provided: uint,
    stable-provided: uint
}
```

### Constants

| Name                     | Value   | Description                           |
| ------------------------ | ------- | ------------------------------------- |
| MINIMUM-COLLATERAL-RATIO | 150     | Minimum required collateral ratio (%) |
| LIQUIDATION-RATIO        | 130     | Ratio triggering liquidation (%)      |
| MINIMUM-DEPOSIT          | 1000000 | Minimum BTC deposit (sats)            |
| POOL-FEE-RATE            | 3       | Pool fee rate (0.3%)                  |
| PRECISION                | 1000000 | Price precision (6 decimals)          |

## Function Details

### Initialization Functions

#### initialize

```clarity
(define-public (initialize (initial-price uint))
```

- Sets initial BTC/USD price
- Can only be called once
- Requires contract owner

#### update-price

```clarity
(define-public (update-price (new-price uint))
```

- Updates BTC/USD price
- Requires contract owner
- Validates price range

### Vault Operations

#### deposit-collateral

```clarity
(define-public (deposit-collateral (btc-amount uint))
```

- Locks BTC as collateral
- Requires minimum deposit
- Updates vault state

#### mint-stablecoin

```clarity
(define-public (mint-stablecoin (amount uint))
```

- Creates new stablecoins
- Checks collateral ratio
- Updates total supply

#### burn-stablecoin

```clarity
(define-public (burn-stablecoin (amount uint))
```

- Burns stablecoins
- Reduces vault debt
- Updates total supply

### Liquidity Operations

#### add-liquidity

```clarity
(define-public (add-liquidity (btc-amount uint) (stable-amount uint))
```

- Adds liquidity to pool
- Calculates LP tokens
- Updates pool balances

#### remove-liquidity

```clarity
(define-public (remove-liquidity (lp-tokens uint))
```

- Removes liquidity
- Returns assets
- Updates LP state

## Error Handling

### Error Codes

| Code | Name                        | Description                      |
| ---- | --------------------------- | -------------------------------- |
| 1000 | ERR-NOT-AUTHORIZED          | Unauthorized access attempt      |
| 1001 | ERR-INSUFFICIENT-BALANCE    | Insufficient funds for operation |
| 1002 | ERR-INVALID-AMOUNT          | Invalid amount specified         |
| 1003 | ERR-INSUFFICIENT-COLLATERAL | Collateral ratio too low         |
| 1004 | ERR-POOL-EMPTY              | Liquidity pool is empty          |
| 1005 | ERR-SLIPPAGE-TOO-HIGH       | Price impact exceeds limit       |
| 1006 | ERR-BELOW-MINIMUM           | Amount below minimum             |
| 1007 | ERR-ABOVE-MAXIMUM           | Amount above maximum             |
| 1008 | ERR-ALREADY-INITIALIZED     | Contract already initialized     |
| 1009 | ERR-NOT-INITIALIZED         | Contract not initialized         |
| 1010 | ERR-INVALID-PRICE           | Invalid price value              |

## Mathematical Formulas

### Collateral Ratio Calculation

```
collateral_ratio = (btc_amount * btc_price * 100) / stablecoin_amount
```

### LP Token Calculation

```
lp_tokens = sqrt(btc_amount * stable_amount)  // Initial liquidity
lp_tokens = (btc_amount * sqrt(pool_btc * pool_stable)) / pool_btc  // Additional liquidity
```

## Security Considerations

1. **Access Control**

   - Owner-only functions
   - Proper authorization checks
   - State validation

2. **Economic Security**

   - Minimum collateral ratio
   - Liquidation threshold
   - Price validation

3. **Technical Security**
   - Safe math operations
   - Balance checks
   - State consistency

## Integration Guide

### Contract Deployment

1. Deploy contract
2. Initialize with valid price
3. Verify deployment

### Interaction Examples

1. **Depositing Collateral**

```clarity
(contract-call? .btc-stablecoin-bridge deposit-collateral u1000000)
```

2. **Minting Stablecoins**

```clarity
(contract-call? .btc-stablecoin-bridge mint-stablecoin u500000)
```

3. **Adding Liquidity**

```clarity
(contract-call? .btc-stablecoin-bridge add-liquidity u1000000 u50000000)
```

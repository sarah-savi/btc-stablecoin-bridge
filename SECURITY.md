# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of BTC-Stablecoin Bridge seriously. If you believe you have found a security vulnerability, please report it to us as described below.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to [sarahobangha@gmail.com](mailto:sarahobangha@gmail.com)

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the requested information listed below (as much as you can provide) to help us better understand the nature and scope of the possible issue:

- Type of issue
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit the issue

## Smart Contract Security Considerations

### Critical Security Parameters

1. **Minimum Collateral Ratio (150%)**

   - Ensures system solvency
   - Provides buffer against price fluctuations

2. **Liquidation Ratio (130%)**

   - Triggers liquidation before insolvency
   - Protects system stability

3. **Price Oracle**
   - Only authorized updates
   - Validation of price ranges

### Known Security Measures

1. **Access Control**

   - Contract owner restrictions
   - Function-level authorization

2. **Input Validation**

   - Amount checks
   - Balance verification
   - Price range validation

3. **Arithmetic Safety**

   - Safe math operations
   - Overflow prevention
   - Precision handling

4. **State Management**
   - Atomic operations
   - Consistent state updates
   - Balance tracking

### Security Best Practices

1. **For Users**

   - Monitor collateral ratios
   - Understand liquidation risks
   - Verify transactions

2. **For Developers**

   - Follow audit recommendations
   - Test thoroughly
   - Document changes

3. **For Auditors**
   - Review access controls
   - Check mathematical operations
   - Verify state consistency

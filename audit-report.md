# Smart Contract Audit Report
## VulnerableLending Protocol

**Date:** April 2026  
**Auditor:** [Loccturno](https://github.com/Loccturno)  
**Severity Scale:** Critical / High / Medium / Low

---

## Executive Summary

A security audit was performed on the `VulnerableLending.sol` contract.
Two critical design vulnerabilities were identified, one of which allows 
complete drainage of protocol funds with zero financial risk to the attacker.
A fixed implementation (`FixedLending.sol`) is provided.

---

## Findings

### [CRITICAL] Uncollateralized Borrowing

**Severity:** Critical  
**Contract:** VulnerableLending.sol  
**Function:** `borrow()`, `withdraw()`

**Description:**  
The protocol requires 50% collateral to borrow funds, but does not lock 
the collateral after a loan is issued. An attacker can deposit collateral, 
borrow against it, and immediately withdraw the full collateral — leaving 
an active loan with zero backing.

**Attack Scenario:**
1. deposit(2 ETH)   → attacker has 2 ETH collateral in protocol
2. borrow(1 ETH)    → attacker receives 1 ETH loan
3. withdraw(2 ETH)  → attacker reclaims full collateral
Result: +1 ETH profit, zero collateral remaining
**Proof of Concept:**  
Demonstrated on Remix VM. Transaction hashes:
- deposit: `0x94d81103d928cd4209214e735affd6cc38d5d4139b3e7aeabb498dc3b8727a85`
- borrow: `0x88ee88c1668b8cf9ea8899b38ac983e049c2b92c7a0c97fd8a3921827ab7df91`
- withdraw: `0x87ef89f5c2bca2223e12a4f63b9a82546a0538664c5881088ddbb459e300e927`

**Impact:**  
Complete drainage of protocol liquidity. Every depositor loses funds.

**Fix:**  
Introduce `lockedCollateral` mapping. Lock collateral on borrow, 
unlock on repay. Prevent withdrawal of locked funds.

```solidity
// In borrow():
lockedCollateral[msg.sender] += collateralNeeded;

// In withdraw():
uint256 available = deposits[msg.sender] - lockedCollateral[msg.sender];
require(available >= amount, "Insufficient available deposit");
```

**Fix Verification:**  
Same attack attempted on `FixedLending.sol` — reverts as expected:
- withdraw attempt: `0xf49de6e4e57a39e7d000d49bd2269fa8b504bc8a90d2cde970d36b828780ff2e`
- Reason: "Insufficient available deposit" ✅

---

### [LOW] No Interest Rate Mechanism

**Severity:** Low  
**Contract:** VulnerableLending.sol

**Description:**  
The protocol has no interest on loans. Borrowers have no financial 
incentive to repay. This is a design gap rather than a security 
vulnerability, but makes the protocol economically unviable.

**Recommendation:**  
Implement a time-based interest rate or a fixed fee on borrowing.

---

### [LOW] No Liquidation Mechanism

**Severity:** Low  
**Contract:** VulnerableLending.sol

**Description:**  
If collateral value drops (in a multi-asset scenario), there is no 
mechanism to liquidate undercollateralized positions. Protocol funds
remain at risk.

**Recommendation:**  
Implement a liquidation function callable by anyone when a position 
becomes undercollateralized.

---

## Fixed Contract

See `FixedLending.sol` for the corrected implementation.

Key changes:
- `lockedCollateral` mapping prevents collateral withdrawal during active loans
- Check-Effects-Interactions pattern applied in `withdraw()` and `borrow()`
- Collateral unlocked proportionally on `repay()`

---

## Disclaimer

This audit was performed for educational purposes on a deliberately 
vulnerable contract. It does not constitute a full production audit.

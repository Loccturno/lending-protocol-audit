# Lending Protocol Audit

Educational smart contract audit demonstrating an uncollateralized 
borrowing vulnerability in a DeFi lending protocol.

## Contents
- `VulnerableLending.sol` — Protocol with critical vulnerability
- `FixedLending.sol` — Patched implementation  
- `audit-report.md` — Full audit report with PoC

## Vulnerability
A critical flaw allows attackers to borrow funds and withdraw 
collateral in the same transaction, resulting in undercollateralized 
loans and protocol drainage.

## Tools
Solidity 0.8.0 / Remix IDE

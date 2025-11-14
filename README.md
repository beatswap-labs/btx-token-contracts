# BTX Token Contracts

This repository includes two Solidity contracts used for the BTX token and scheduled-release distributions.

---

## Contract Files

### beatswap.sol

ERC20 token contract defining the BTX token name, symbol, initial supply, and burn capability.

### tokenvestinglock.sol

Distributes BTX to multiple accounts according to predefined shares and a time-based release schedule.  
Vested tokens are distributed when `release()` is executed.  
Anyone may call `release()`.

---

## Allocation Categories

Each allocation group uses its own multisig vault.  
Groups requiring scheduled release send their allocations into the tokenvestinglock contract.

### Tier-Based Groups

- Seed Tier Vault *(into tokenvestinglock)*
- Round A Tier Vault *(into tokenvestinglock)*
- Round B Tier Vault *(into tokenvestinglock)*
- Public Round Tier Vault

### Contributors & Internal Roles

- Team Vault *(into tokenvestinglock)*
- Advisors Vault *(into tokenvestinglock)*

### Ecosystem Operations

- Liquidity Vault
- Marketing and Partnerships Vault
- Staking and Community Rewards Vault
- Treasury Vault *(into tokenvestinglock)*

### Product & Expansion

- Licensing to Earn Vault
- IP-Rights Acquisition Vault *(into tokenvestinglock)*
- RWA Pairing Liquidity Vault *(into tokenvestinglock)*
- PoR Rewards Vault

Multisig vaults are created using Safe.global.

---

## Token Flow

1. Deployment mint → initial recipient  
2. Initial recipient → multisig vaults  
3. (If applicable) multisig vault → TokenVestingLock  
4. Vested tokens distributed through `release()`

---

## License

MIT License.

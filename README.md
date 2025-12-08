# BTX Token Contracts

This repository includes two Solidity contracts used for the BTX token and scheduled-release distributions.

---

## Contract Files

### **beatswap.sol**
ERC20 (BNB Chain) token contract defining the BTX token name, symbol, initial supply, and burn capability.

### **tokenvestinglock.sol**
Distributes BTX to multiple accounts according to predefined shares and a time-based release schedule.  
Vested tokens are distributed when `release()` is executed.  
Anyone may call `release()`.

---

## Contract Addresses

**BTX Token (BNB Smart Chain Mainnet)**  
• Token Contract: `0xAa242a47F4cC074E59cbC7D65309B1F21202AaA3`  
• Token Name: **BeatSwap**  
• Token Symbol: **BTX**  
• Decimals: **18**  
• BscScan Verification:  
https://bscscan.com/token/0xAa242a47F4cC074E59cbC7D65309B1F21202AaA3

---

## Allocation Categories

Each allocation group uses its own multisig vault.  
Groups requiring scheduled release send their allocations into the TokenVestingLock contract.

---

## Tier-Based Groups

- Seed Tier Vault *(into tokenvestinglock)*
- Round A Tier Vault *(into tokenvestinglock)*
- Round B Tier Vault *(into tokenvestinglock)*
- Public Round Tier Vault

## Contributors & Internal Roles

- Team Vault *(into tokenvestinglock)*
- Advisors Vault *(into tokenvestinglock)*

## Ecosystem Operations

- Liquidity Vault
- Marketing and Partnerships Vault
- Staking and Community Rewards Vault
- Treasury Vault *(into tokenvestinglock)*

## Product & Expansion

- Licensing to Earn Vault
- IP-Rights Acquisition Vault *(into tokenvestinglock)*
- RWA Pairing Liquidity Vault *(into tokenvestinglock)*
- PoR Rewards Vault

---

## Allocation Table

| Allocation Category | MultiSig Vault Address | TokenVestingLock |
|---------------------|------------------------|------------------|
| **Seed Tier Vault** | `0x8fF979d78E718b44e6099c900824e8c7B0ca77Bb` | **TBD** |
| **Round A Tier Vault** | `0x9D3169CeB0A2b040700010fB0fDC27fF71068555` | **TBD** |
| **Round B Tier Vault** | `0x195b849675Cd4220206805E03420be4AEcFd33f1` | **TBD** |
| **Public Round Tier Vault** | `0x62382d13B909B611c17b54Eb19F8E5BC3d9C1e24` | **N/A** |
| **Team Vault** | `0x8B3Ab179Edb1816531968F5b6eEFcbDc7A74Af5f` | **TBD** |
| **Advisors Vault** | `0xE9199e835A2206e45853280AF28baf21DFDdB67A` | **TBD** |
| **Liquidity Vault** | `0xbEd1a2ed890Ccd1A5f7b5305B82cc33b0Fd963Cc` | **N/A** |
| **Marketing and Partnerships Vault** | `0x26e0Dc3D7e2DcdE7Eb3c2756fAF841DDD4EfaB18` | **N/A** |
| **Staking and Community Rewards Vault** | `0xBbe61C03F760Dc84434651838461373f4Ad1cd34` | **N/A** |
| **Treasury Vault** | `0x77D2E77e1c2a2A8A16Ea57d874b179a6Aed42713` | **TBD** |
| **Licensing to Earn Vault** | `0x8aF28b25839cdF658f4432089F23DD37acC0af7E` | **N/A** |
| **IP-Rights Acquisition Vault** | `0x763458F4bDcbd7ce8342A78F49Bc4e395a73511e` | **TBD** |
| **RWA Pairing Liquidity Vault** | `0xaf11B8A952922FDB8F66040928248C22F09f4A74` | **TBD** |
| **PoR Rewards Vault** | `0x938f14C8dF63f1c286183E1485b1B5364DD6B77D` | **N/A** |

---

## Security & Distribution Policy

The initial mint is immediately redistributed in full to the designated multi-sig vaults.  
No BTX tokens remain in any externally-owned account (EOA) after deployment.  
Multisig vaults are created using Safe.global.  
Multi-sig wallets follow a 2-of-3 Safe configuration to prevent single-key compromise.

**Signers:**  
Signer 1: `0xa7F7ef6946427932547d44cF1132c54269cd379A`  
Signer 2: `0x61C82f55A86593DB82c45B2cf48dF4c4852a0c2D`  
Signer 3: `0x2dc6de8EC6d4b4f175dbb40a523D7aA03F70280A`

---

### External Security Audit

• CertiK Audit / Skynet Page:  
https://skynet.certik.com/projects/beatswap

---

## Token Flow

1. **Deployment mint → Initial recipient**  
   Safe multi-sig:`0x208d99B94C63d8A1bA2daf31737fFcdA4D16bc98`   
3. **Initial recipient → Immediate redistribution → all multisig vaults**  
4. **(If applicable) multisig vault → TokenVestingLock**  
5. **Vested tokens distributed through `release()`**

---

## Published Token Distribution Plan

https://beatswap.gitbook.io/beatswap/tokenomics/usdbtx-tokenomics#allocation-breakdown

---

## License

MIT License.

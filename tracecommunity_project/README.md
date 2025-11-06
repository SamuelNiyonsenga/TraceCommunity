# TraceCommunity — Demo Project (Agribusiness: all products)
This package is a ready-to-run demo of **TraceCommunity**, a lightweight supply-chain provenance system for community cooperatives (milk, coffee, vegetables, honey — mixed agribusiness demo).

## What's included
- `contracts/BatchRegistry.sol` — Solidity smart contract (role-based batch registry)
- `scripts/deploy.js` — Hardhat deploy & seed script (creates roles & demo batch)
- `src/` — Simple React frontend (App.jsx, index.js) showing batch verification
- `package.json` — project dependencies and scripts
- `one_page_summary.txt` & `one_page_summary.pdf` — 1-page submission summary for festival
- `slides.md` — pitch slide text you can paste into PowerPoint or Google Slides
- `README.md` — this file

## Quick setup (demo for tomorrow)
1. Install dependencies:
```bash
npm install
```
2. Start a local Hardhat node in one terminal:
```bash
npx hardhat node
```
3. In another terminal deploy and seed demo data:
```bash
node scripts/deploy.js
```
4. Start the React app:
```bash
npm start
```
5. Open Chrome, import one of the private keys from the Hardhat node into MetaMask (logs displayed in the hardhat node console), switch accounts to demo actions (coopAdmin, producer, inspector), and interact with the app. Replace `REPLACE_WITH_DEPLOYED_ADDRESS` in `src/BatchRegistryABI.json` or `App.jsx` with the deployed contract address shown by the deploy script.

## Notes
- To compile the contract and get the real ABI, run `npx hardhat compile` and copy the artifact `artifacts/contracts/BatchRegistry.sol/BatchRegistry.json` `abi` section to `src/BatchRegistryABI.json`.
- For production, consider a permissioned chain (consortium) and IPFS / encrypted off-chain storage for sensitive files.
- Keep PII off-chain to preserve privacy.

Good luck at the Africa Blockchain Festival — present the demo using the seeded batch (ID 1) and the verification page!

Contact: Samuel Niyonsenga

// ✅ Declare MetaMask's Ethereum provider in TypeScript
interface Window {
    ethereum?: import("ethers").providers.ExternalProvider;
  }
  
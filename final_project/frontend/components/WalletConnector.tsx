import { useState } from "react";
import { BrowserProvider } from "ethers";

// ✅ Define props type
interface WalletConnectorProps {
  onWalletConnected: (provider: BrowserProvider) => void;
}

export default function WalletConnector({ onWalletConnected }: WalletConnectorProps) {
  const [account, setAccount] = useState<string | null>(null);

  async function connectWallet() {
    if (window.ethereum) {
      try {
        const provider = new BrowserProvider(window.ethereum);
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        setAccount(accounts[0]);
        onWalletConnected(provider); // ✅ Now correctly typed
      } catch (error) {
        console.error("Wallet connection failed:", error);
      }
    } else {
      alert("MetaMask is not installed. Please install it to continue.");
    }
  }

  return (
    <div>
      {account ? (
        <p>Connected: {account.substring(0, 6)}...{account.slice(-4)}</p>
      ) : (
        <button onClick={connectWallet}>Connect MetaMask</button>
      )}
    </div>
  );
}

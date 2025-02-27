import { useState } from "react";
import { BrowserProvider } from "ethers";
import React from "react";

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
        onWalletConnected(provider);
      } catch (error) {
        console.error("Wallet connection failed:", error);
      }
    } else {
      alert("MetaMask is not installed. Please install it to continue.");
    }
  }

  return (
    <div className="flex flex-col items-center justify-center">
      {account ? (
        <p className="text-green-600 text-lg font-semibold">
          Connected: {account.substring(0, 6)}...{account.slice(-4)}
        </p>
      ) : (
        <button
          onClick={connectWallet}
          className="px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 transition"
        >
          Connect MetaMask
        </button>
      )}
    </div>
  );
}

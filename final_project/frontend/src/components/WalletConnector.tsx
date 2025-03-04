import { useState, useEffect } from "react";
import { BrowserProvider } from "ethers";

interface WalletConnectorProps {
  onWalletConnected: (provider: BrowserProvider) => void;
}

export default function WalletConnector({ onWalletConnected }: WalletConnectorProps) {
  const [account, setAccount] = useState<string | null>(null);

  // Check for an already connected wallet on component mount
  useEffect(() => {
    async function checkConnectedWallet() {
      if (window.ethereum) {
        try {
          const provider = new BrowserProvider(window.ethereum);
          const accounts = await window.ethereum.request({ method: "eth_accounts" });

          if (accounts.length > 0) {
            setAccount(accounts[0]);
            onWalletConnected(provider);
          }
        } catch (error) {
          console.error("Failed to check connected wallet:", error);
        }
      }
    }

    checkConnectedWallet();
  }, [onWalletConnected]);

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
      console.error("MetaMask is not installed.");
    }
  }

  // Trigger wallet connection automatically
  useEffect(() => {
    if (!account) {
      connectWallet();
    }
  }, [account]);

  // No visual output is returned
  return null;
}
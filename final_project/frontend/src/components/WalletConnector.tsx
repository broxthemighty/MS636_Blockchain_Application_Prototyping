import { useState } from "react";
import { BrowserProvider } from "ethers";

interface WalletConnectorProps {
  onWalletConnected: (provider: BrowserProvider) => void;
}

export default function WalletConnector({ onWalletConnected }: WalletConnectorProps) {
  const [account, setAccount] = useState<string | null>(null);
  const [statusMessage, setStatusMessage] = useState<{ text: string; type: string } | null>(null);

  async function connectWallet() {
    if (window.ethereum) {
      try {
        const provider = new BrowserProvider(window.ethereum);
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        setAccount(accounts[0]);
        onWalletConnected(provider);

        setStatusMessage({
          text: `Wallet Connected: ${accounts[0].substring(0, 6)}...${accounts[0].slice(-4)}`,
          type: "success",
        });
      } catch (error) {
        console.error("Wallet connection failed:", error);
        setStatusMessage({ text: "Failed to connect MetaMask.", type: "error" });
      }
    } else {
      setStatusMessage({ text: "Please install MetaMask to continue.", type: "warning" });
    }
  }

  // No visual output is returned
  return null;
}
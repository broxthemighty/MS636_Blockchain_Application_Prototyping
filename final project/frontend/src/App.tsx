import { useState } from "react";
import WalletConnector from "../components/WalletConnector";
import ContractInteraction from "../components/ContractInteraction";
import { BrowserProvider } from "ethers";
import "./App.css";

export default function App() {
  // ✅ Specify the correct type for provider
  const [provider, setProvider] = useState<BrowserProvider | null>(null);

  return (
    <div className="App">
      <h1>General API Marketplace</h1>
      <WalletConnector onWalletConnected={setProvider} />
      {provider && <ContractInteraction provider={provider} />}
    </div>
  );
}

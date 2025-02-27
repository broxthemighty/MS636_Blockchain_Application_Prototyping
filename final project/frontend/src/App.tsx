import { useState } from "react";
import { BrowserProvider } from "ethers";
import WalletConnector from "./components/WalletConnector";
import APIList from "./components/APIList";
import ContractInteraction from "./components/ContractInteraction";
import AdminPanel from "./components/AdminPanel";

export default function App() {
  //  Fix: Explicitly set the type of `provider` as `BrowserProvider | null`
  const [provider, setProvider] = useState<BrowserProvider | null>(null);

  return (
    <div>
      <h1>General API Marketplace</h1>
      <WalletConnector onWalletConnected={setProvider} />
      {provider && <APIList provider={provider} />}
      {provider && <ContractInteraction provider={provider} />}
      {provider && <AdminPanel provider={provider} />}
    </div>
  );
}

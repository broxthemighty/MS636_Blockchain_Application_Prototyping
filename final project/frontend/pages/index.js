import WalletConnector from "../components/WalletConnector";
import ContractInteraction from "../components/ContractInteraction";

export default function Home() {
  return (
    <div>
      <h1>General API Marketplace</h1>
      <WalletConnector />
      <ContractInteraction />
    </div>
  );
}
import { useState, useEffect } from "react";
import { BrowserProvider, Contract, Interface } from "ethers";
import contractABI from "../contracts/GeneralApiMarketplaceToken.json" assert { type: "json" }; // ✅ Explicit JSON import

interface ContractInteractionProps {
  provider: BrowserProvider;
}

export default function ContractInteraction({ provider }: ContractInteractionProps) {
  const [contract, setContract] = useState<Contract | null>(null);
  const [apiCount, setApiCount] = useState<number>(0);

  useEffect(() => {
    if (!provider) return;

    async function loadContract() {
      const signer = await provider.getSigner();
      const contractInterface = new Interface(contractABI); // ✅ Fix ABI type issue
      const contractInstance = new Contract("0xYourContractAddress", contractInterface, signer);
      setContract(contractInstance);

      try {
        const count = await contractInstance.apiIdCounter();
        setApiCount(Number(count));
      } catch (error) {
        console.error("Error fetching API count:", error);
      }
    }

    loadContract();
  }, [provider]);

  return (
    <div>
      <h2>API Marketplace</h2>
      <p>Number of APIs: {apiCount}</p>
      {contract && <p>Contract Loaded Successfully</p>}
    </div>
  );
}

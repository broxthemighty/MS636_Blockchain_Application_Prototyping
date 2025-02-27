import { useEffect } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";


interface ContractInteractionProps {
  provider: BrowserProvider;
}

export default function ContractInteraction({ provider }: ContractInteractionProps) {
  useEffect(() => {
    if (!provider) return;

    async function fetchApiCount() {
      try {
        const signer = await provider.getSigner();
        const contract = new Contract(CONTRACT_ADDRESS,
          ABI,
          signer
        );
        await contract.apiIdCounter(); // fetch data but do nothing with it
      } catch (error) {
        console.error("Error fetching API count:", error);
      }
    }

    fetchApiCount();
  }, [provider]);

  return null; // no UI is rendered
}

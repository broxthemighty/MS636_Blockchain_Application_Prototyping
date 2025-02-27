import { useEffect } from "react";
import { BrowserProvider, Contract } from "ethers";
import contractABI from "../../contracts/GeneralApiMarketplaceToken.json" with { type: "json" };

interface ContractInteractionProps {
  provider: BrowserProvider;
}

export default function ContractInteraction({ provider }: ContractInteractionProps) {
  useEffect(() => {
    if (!provider) return;

    async function fetchApiCount() {
      try {
        const signer = await provider.getSigner();
        const contract = new Contract(
          "0xd119f71ad07cC8D59d3000e9387Cb559eC33dB78",
          contractABI,
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

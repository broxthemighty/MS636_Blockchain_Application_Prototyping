import { useEffect, useState } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import { Box, Text, Button } from "@chakra-ui/react";

interface ContractInteractionProps {
  provider: BrowserProvider;
}

export default function ContractInteraction({ provider }: ContractInteractionProps) {
  const [apiCount, setApiCount] = useState<number | null>(null);

  useEffect(() => {
    if (!provider) return;

    async function fetchApiCount() {
      try {
        const signer = await provider.getSigner();
        const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);
        const count = await contract.apiIdCounter();
        setApiCount(Number(count));
      } catch (error) {
        console.error("Error fetching API count:", error);
      }
    }

    fetchApiCount();
  }, [provider]);

  return (
    <Box textAlign="center" p={4}>
      <Text fontSize="xl" fontWeight="bold">
        Total APIs: {apiCount !== null ? apiCount : "Loading..."}
      </Text>
      <Button colorScheme="blue" mt={2} onClick={() => window.location.reload()}>
        Refresh
      </Button>
    </Box>
  );
}

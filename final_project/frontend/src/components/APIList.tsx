import { useState, useEffect } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import { Box, SimpleGrid, Text, Flex } from "@chakra-ui/react";

interface API {
  id: number;
  name: string;
  pricePerRequest: number;
  totalPurchases: number;
  isActive: boolean;
}

interface Props {
  provider: BrowserProvider;
}

export default function APIList({ provider }: Props) {
  const [apis, setApis] = useState<API[]>([]);

  async function fetchAPIs() {
    if (!provider || !CONTRACT_ADDRESS) return;

    try {
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

      const apiCount = await contract.apiIdCounter();
      const fetchedAPIs: API[] = [];

      for (let i = 0; i < apiCount; i++) {
        const api = await contract.apis(i);
        fetchedAPIs.push({
          id: i,
          name: api.name,
          pricePerRequest: Number(api.pricePerRequest),
          totalPurchases: Number(api.totalPurchases),
          isActive: Boolean(api.isActive),
        });
      }

      setApis(fetchedAPIs);
    } catch (error) {
      console.error("Error fetching API list:", error);
    }
  }

  useEffect(() => {
    fetchAPIs();
    const interval = setInterval(fetchAPIs, 5000);
    return () => clearInterval(interval);
  }, [provider]);

  return (
    <Box>
      {apis.length > 0 ? (
        <SimpleGrid columns={{ base: 1, md: 2, lg: 3 }} gap={6}>
          {apis.map((api) => (
            <Box key={api.id} p={4} shadow="md" borderRadius="lg" bg="white" borderWidth="1px">
              <Text fontSize="lg" fontWeight="bold" color="gray.800">
                {api.name}
              </Text>
              <Text fontSize="md" color="gray.600">
                💰 Price: {api.pricePerRequest} Tokens
              </Text>
              <Text fontSize="md" color="gray.600">
                📈 Purchases: {api.totalPurchases}
              </Text>
              <Flex justify="center" mt={2}>
                <Text
                  fontSize="md"
                  fontWeight="semibold"
                  color={api.isActive ? "green.500" : "red.500"}
                >
                  {api.isActive ? "🟢 Active" : "🔴 Inactive"}
                </Text>
              </Flex>
            </Box>
          ))}
        </SimpleGrid>
      ) : (
        <Text fontSize="md" color="gray.600">
          No APIs found
        </Text>
      )}
    </Box>
  );
}
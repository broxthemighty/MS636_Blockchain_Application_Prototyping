import { useState, useEffect } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import { Box, SimpleGrid, Text, Flex, Input, Button, VStack, Spinner } from "@chakra-ui/react";

interface API {
  id: number;
  name: string;
  pricePerRequest: number;
  subscriptionPrice: number;
  subscriptionDuration: number;
  totalPurchases: number;
  isActive: boolean;
}

interface Props {
  provider: BrowserProvider;
}

export default function APIList({ provider }: Props) {
  const [apis, setApis] = useState<API[]>([]);
  const [requests, setRequests] = useState<{ [key: number]: number }>({});
  const [isLoading, setIsLoading] = useState(false); // Loading state

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
          subscriptionPrice: Number(api.subscriptionPrice),
          subscriptionDuration: Number(api.subscriptionDuration),
          totalPurchases: Number(api.totalPurchases),
          isActive: Boolean(api.isActive),
        });
      }

      setApis(fetchedAPIs);
    } catch (error) {
      console.error("Error fetching API list:", error);
    }
  }

  async function purchaseAPIAccess(apiId: number, requests: number) {
    if (!provider || !CONTRACT_ADDRESS) return;

    setIsLoading(true); // Start loading

    try {
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

      // Call the approveAndPurchaseAPIAccess function in the smart contract
      const tx = await contract.approveAndPurchaseAPIAccess(apiId, requests);
      await tx.wait();

      alert("API access purchased successfully!");
      fetchAPIs(); // Refresh the API list
    } catch (error) {
      console.error("Error purchasing API access:", error);
      alert("Failed to purchase API access. Please try again.");
    } finally {
      setIsLoading(false); // Stop loading
    }
  }

  async function purchaseSubscription(apiId: number) {
    if (!provider || !CONTRACT_ADDRESS) return;
  
    setIsLoading(true); // Start loading
  
    try {
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);
  
      // Call the approveAndPurchaseSubscription function in the smart contract
      const tx = await contract.approveAndPurchaseSubscription(apiId);
      await tx.wait();
  
      alert("Subscription purchased successfully!");
      fetchAPIs(); // Refresh the API list
    } catch (error) {
      console.error("Error purchasing subscription:", error);
      alert("Failed to purchase subscription. Please try again.");
    } finally {
      setIsLoading(false); // Stop loading
    }
  }

  async function useAPIAccess(apiId: number) {
    if (!provider || !CONTRACT_ADDRESS) return;

    setIsLoading(true); // Start loading

    try {
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

      // Call the useAPIAccess function in the smart contract
      const tx = await contract.useAPIAccess(apiId);
      await tx.wait();

      alert("API access used successfully!");
      fetchAPIs(); // Refresh the API list
    } catch (error) {
      console.error("Error using API access:", error);
      alert("Failed to use API access. Please try again.");
    } finally {
      setIsLoading(false); // Stop loading
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
        <SimpleGrid columns={{ base: 3, md: 4, lg: 5 }} gap={6}>
          {apis.map((api) => (
            <Box key={api.id} p={4} shadow="md" borderRadius="lg" bg="white" borderWidth="1px">
              <Flex justify="left" mt={2}>
                <Text
                  fontSize="md"
                  fontWeight="semibold"
                  color={api.isActive ? "green.500" : "red.500"}
                >
                  {api.isActive ? "🟢 Active" : "🔴 Inactive"}
                </Text>
              </Flex>
              <Text fontSize="lg" fontWeight="bold" color="gray.800">
                {api.name}
              </Text>
              <Text fontSize="md" color="gray.600">
                💰 Price: {api.pricePerRequest} <br />Tokens per request<br /><br />
              </Text>
              <Text fontSize="md" color="gray.600">
                📈 Purchases: {api.totalPurchases}<br /><br />
              </Text>
              <Text fontSize="md" color="gray.600">
                🕒 Subscription: {api.subscriptionPrice} <br />Tokens for {api.subscriptionDuration} seconds
              </Text>

              {/* Purchase Access Section */}
              <VStack mt={4} gap={2}>
                <Input
                  type="number"
                  placeholder="Number of requests"
                  value={requests[api.id] || ""}
                  onChange={(e) =>
                    setRequests((prev) => ({
                      ...prev,
                      [api.id]: parseInt(e.target.value, 10),
                    }))
                  }
                  size="sm"
                  width="100%"
                />
                <Button
                  onClick={() => purchaseAPIAccess(api.id, requests[api.id] || 0)}
                  colorScheme="blue"
                  size="sm"
                  color="gray"
                  disabled={!api.isActive || isLoading} // Disable button while loading
                  border="1px solid"
                  borderColor="gray.300"
                  width="100%"
                >
                  {isLoading ? <Spinner size="sm" /> : "Purchase Access"}
                </Button>
              </VStack>

              {/* Purchase Subscription Section */}
              <VStack mt={4} gap={2}>
                <Button
                  onClick={() => purchaseSubscription(api.id)}
                  colorScheme="green"
                  size="sm"
                  color="gray"
                  disabled={!api.isActive || isLoading}
                  border="1px solid"
                  borderColor="gray.300"
                  width="100%"
                >
                  {isLoading ? <Spinner size="sm" /> : "Purchase Subscription"}
                </Button>
              </VStack>

              {/* Use API Access Section */}
              <VStack mt={4} gap={2}>
                <Button
                  onClick={() => useAPIAccess(api.id)}
                  colorScheme="purple"
                  size="sm"
                  color="gray"
                  disabled={!api.isActive || isLoading}
                  border="1px solid"
                  borderColor="gray.300"
                  width="100%"
                >
                  {isLoading ? <Spinner size="sm" /> : "Use API Access"}
                </Button>
              </VStack>
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
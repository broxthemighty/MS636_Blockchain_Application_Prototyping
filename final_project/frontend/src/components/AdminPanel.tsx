import { useState } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import { Box, Heading, Input, Button, VStack } from "@chakra-ui/react";

interface Props {
  provider: BrowserProvider;
}

export default function AdminPanel({ provider }: Props) {
  const [apiName, setApiName] = useState("");
  const [pricePerRequest, setPricePerRequest] = useState("");
  const [subscriptionPrice, setSubscriptionPrice] = useState("");
  const [subscriptionDuration, setSubscriptionDuration] = useState("");

  async function registerAPI() {
    if (!provider) return;
    const signer = await provider.getSigner();
    const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

    try {
      const tx = await contract.registerAPI(
        apiName,
        BigInt(pricePerRequest), // Ensure uint256 conversion
        BigInt(subscriptionPrice),
        BigInt(subscriptionDuration)
      );
      await tx.wait();
      alert("API registered successfully!");
    } catch (error) {
      console.error("Error registering API:", error);
    }
  }

  return (
    <Box>
      <VStack gap={2}>
        <Input
          value={apiName}
          onChange={(e) => setApiName(e.target.value)}
          placeholder="API Name"
          variant="outline"
          size="sm" // Smaller input size
        />
        <Input
          type="number"
          value={pricePerRequest}
          onChange={(e) => setPricePerRequest(e.target.value)}
          placeholder="Price Per Request"
          variant="outline"
          size="sm" // Smaller input size
        />
        <Input
          type="number"
          value={subscriptionPrice}
          onChange={(e) => setSubscriptionPrice(e.target.value)}
          placeholder="Subscription Price"
          variant="outline"
          size="sm" // Smaller input size
        />
        <Input
          type="number"
          value={subscriptionDuration}
          onChange={(e) => setSubscriptionDuration(e.target.value)}
          placeholder="Subscription Duration (seconds)"
          variant="outline"
          size="sm" // Smaller input size
        />
        <Button onClick={registerAPI} colorScheme="blue" width="full" size="sm"> {/* Smaller button size */}
          Register API
        </Button>
      </VStack>
    </Box>
  );
}
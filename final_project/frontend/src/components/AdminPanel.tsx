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
        BigInt(pricePerRequest),
        BigInt(subscriptionPrice),
        BigInt(subscriptionDuration)
      );
      await tx.wait();
      alert("API registered successfully!");
    } catch (error) {
      console.error("Error registering API:", error);
      alert("Failed to register API. Please try again.");
    }
  }

  async function withdrawEarnings() {
    if (!provider) return;
    const signer = await provider.getSigner();
    const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

    try {
      const tx = await contract.withdrawEarnings();
      await tx.wait();
      alert("Earnings withdrawn successfully!");
    } catch (error) {
      console.error("Error withdrawing earnings:", error);
      alert("Failed to withdraw earnings. Please try again.");
    }
  }

  return (
    <Box>
      <VStack gap={3}>
        <Heading size="md" mb={4}>Admin Panel</Heading>

        {/* Register API Section */}
        <Input
          value={apiName}
          onChange={(e) => setApiName(e.target.value)}
          placeholder="API Name"
          variant="outline"
        />
        <Input
          type="number"
          value={pricePerRequest}
          onChange={(e) => setPricePerRequest(e.target.value)}
          placeholder="Price Per Request"
          variant="outline"
        />
        <Input
          type="number"
          value={subscriptionPrice}
          onChange={(e) => setSubscriptionPrice(e.target.value)}
          placeholder="Subscription Price"
          variant="outline"
        />
        <Input
          type="number"
          value={subscriptionDuration}
          onChange={(e) => setSubscriptionDuration(e.target.value)}
          placeholder="Subscription Duration (seconds)"
          variant="outline"
        />
        <Button onClick={registerAPI} colorScheme="blue" width="full">
          Register API
        </Button>

        {/* Withdraw Earnings Section */}
        <Button onClick={withdrawEarnings} colorScheme="green" width="full">
          Withdraw Earnings
        </Button>
      </VStack>
    </Box>
  );
}
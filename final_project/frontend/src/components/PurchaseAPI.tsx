import { useState } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import { Box, Heading, Input, Button, VStack, Text } from "@chakra-ui/react";

const RegisterAPI = () => {
  const [name, setName] = useState("");
  const [pricePerRequest, setPricePerRequest] = useState("");
  const [subscriptionPrice, setSubscriptionPrice] = useState("");
  const [subscriptionDuration, setSubscriptionDuration] = useState("");
  const [statusMessage, setStatusMessage] = useState({ text: "", type: "" }); // Store messages

  const registerAPI = async () => {
    if (!window.ethereum) {
      setStatusMessage({ text: "MetaMask Required: Please install MetaMask to continue.", type: "error" });
      return;
    }

    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

    try {
      const tx = await contract.registerAPI(
        name,
        ethers.parseEther(pricePerRequest),
        ethers.parseEther(subscriptionPrice),
        parseInt(subscriptionDuration) * 86400 // Convert days to seconds
      );
      await tx.wait();

      setStatusMessage({ text: "API has been successfully registered.", type: "success" });

      // Reset input fields
      setName("");
      setPricePerRequest("");
      setSubscriptionPrice("");
      setSubscriptionDuration("");
    } catch (err) {
      console.error(err);
      setStatusMessage({ text: "Registration Failed: An error occurred while registering the API.", type: "error" });
    }
  };

  return (
    <Box bg="gray.800" p={6} borderRadius="md" color="white" maxW="md" mx="auto" boxShadow="lg">
      <Heading size="lg" mb={4}>Register API</Heading>
      <VStack gap={3}>
        <Input
          type="text"
          placeholder="API Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          bg="gray.700"
          color="white"
          _placeholder={{ color: "gray.400" }}
        />
        <Input
          type="text"
          placeholder="Price Per Request (ETH)"
          value={pricePerRequest}
          onChange={(e) => setPricePerRequest(e.target.value)}
          bg="gray.700"
          color="white"
          _placeholder={{ color: "gray.400" }}
        />
        <Input
          type="text"
          placeholder="Subscription Price (ETH)"
          value={subscriptionPrice}
          onChange={(e) => setSubscriptionPrice(e.target.value)}
          bg="gray.700"
          color="white"
          _placeholder={{ color: "gray.400" }}
        />
        <Input
          type="number"
          placeholder="Subscription Duration (Days)"
          value={subscriptionDuration}
          onChange={(e) => setSubscriptionDuration(e.target.value)}
          bg="gray.700"
          color="white"
          _placeholder={{ color: "gray.400" }}
        />
        <Button colorScheme="blue" width="full" onClick={registerAPI}>
          Register API
        </Button>
        
        {/* Display the status message */}
        {statusMessage.text && (
          <Text color={statusMessage.type === "error" ? "red.400" : "green.400"} fontWeight="bold">
            {statusMessage.text}
          </Text>
        )}
      </VStack>
    </Box>
  );
};

export default RegisterAPI;

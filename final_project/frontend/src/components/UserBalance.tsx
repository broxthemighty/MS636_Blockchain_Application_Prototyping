import { useEffect, useState } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import { Box, Heading, Text } from "@chakra-ui/react";

const UserBalance = () => {
  const [balance, setBalance] = useState("0");

  useEffect(() => {
    const fetchBalance = async () => {
      if (typeof window !== "undefined" && window.ethereum) { // Ensure MetaMask exists
        try {
          const provider = new ethers.BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

          const userAddress = await signer.getAddress();
          const balance = await contract.getUserTokenBalance(userAddress);
          setBalance(ethers.formatEther(balance));
        } catch (error) {
          console.error("Error fetching balance:", error);
        }
      } else {
        console.error("Ethereum provider not found. Make sure MetaMask is installed.");
      }
    };

    fetchBalance();
  }, []);

  return (
    <Box bg="gray.800" p={6} borderRadius="md" color="white" maxW="md" mx="auto" textAlign="center" boxShadow="lg">
      <Heading size="lg" mb={3}>Your Token Balance</Heading>
      <Text fontSize="xl" fontWeight="bold">{balance} Tokens</Text>
    </Box>
  );
};

export default UserBalance;

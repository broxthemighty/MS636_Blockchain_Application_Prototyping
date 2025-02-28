import WalletConnector from "../components/WalletConnector";
import APIList from "../components/APIList";
import AdminPanel from "../components/AdminPanel";
import React from "react";
import { ChakraProvider, Box, Flex, Heading, Text, Button, Input, Divider } from "@chakra-ui/react";

export default function Home({ provider }) {
  return (
    <ChakraProvider>
      <Box bg="gray.900" color="white" minH="100vh" p={6} position="relative">
        {/* Title & API Counter */}
        <Flex justifyContent="center" alignItems="center" flexDirection="column">
          <Heading size="xl">General API Marketplace</Heading>
          <Text fontSize="lg" mt={2}>
            Total APIs: <span id="apiCounter">0</span>
          </Text>
        </Flex>

        {/* Wallet Connection */}
        <Box ml="25%" mt={2}>
          <Text>
            Connected: <span id="walletAddress">0x137f...6ef8</span>
          </Text>
        </Box>

        {/* API List Section */}
        <Box mt={6} ml="25%">
          <Heading size="md">Available APIs</Heading>
          <Button mt={2} colorScheme="blackAlpha">
            Refresh API List 🔄
          </Button>
          
          {/* API List (Replace with dynamic content) */}
          <Box borderWidth={1} p={4} mt={2} borderRadius="lg">
            <Text>testApi1</Text>
            <Text>💰 Price: 1 Tokens</Text>
            <Text>📄 Purchases: 0</Text>
            <Text color="green.400">🟢 Active</Text>
          </Box>
        </Box>

        {/* ✅ Admin Panel (Top-Right Positioning) */}
        <Box position="absolute" top={4} right={4} bg="gray.800" p={6} shadow="lg" borderRadius="lg" w="320px">
          <Heading size="md" mb={4}>Admin Panel</Heading>
          <Input placeholder="API Name" mb={2} />
          <Input type="number" placeholder="Price Per Request" mb={2} />
          <Input type="number" placeholder="Subscription Price" mb={2} />
          <Input type="number" placeholder="Subscription Duration (seconds)" mb={2} />
          <Button colorScheme="blue" width="full">Register API</Button>
        </Box>
      </Box>
    </ChakraProvider>
  );
}
import { useState } from "react";
import { BrowserProvider } from "ethers";
import { ChakraProvider, Box, Heading, Text, Button } from "@chakra-ui/react";
import { defaultSystem } from "@chakra-ui/react";
import WalletConnector from "./components/WalletConnector";
import APIList from "./components/APIList";
import AdminPanel from "./components/AdminPanel";

export default function App() {
  const [provider, setProvider] = useState<BrowserProvider | null>(null);
  const [isAdminPanelOpen, setIsAdminPanelOpen] = useState(false); // State to toggle admin panel

  return (
    <ChakraProvider value={defaultSystem}>
      <Box bg="gray.900" color="white" minH="100vh" p={6} position="relative">
        {/* Wallet Connector */}
        <WalletConnector onWalletConnected={setProvider} />

        {/* Conditionally render content only if provider is available */}
        {provider && (
          <>
            {/* Header */}
            <Box textAlign="center">
              <Heading size="2xl" mb={4}>General API Marketplace</Heading>
              <Text fontSize="lg" mb={6}>
                Wallet Connected: <span id="walletAddress">0x137f...6ef8</span>
              </Text>
            </Box>

            {/* API List Section */}
            <Box mt={6}> {}
              <Heading size="md" mb={4}>Available APIs</Heading>
              <Button mt={2} colorScheme="blackAlpha">
                Refresh API List 🔄
              </Button>

              {/* Dynamic API List */}
              <APIList provider={provider} />
            </Box>

            {/* Admin Panel Toggle Button */}
            <Box position="absolute" top={4} right={4}>
              <Button
                onClick={() => setIsAdminPanelOpen(!isAdminPanelOpen)}
                colorScheme="blue"
              >
                Admin Panel {isAdminPanelOpen ? "<" : "^"} {/* Toggle text symbols */}
              </Button>
            </Box>

            {/* Admin Panel (Conditionally Rendered) */}
            {isAdminPanelOpen && (
              <Box position="absolute" top={16} right={4} bg="gray.800" p={3} shadow="lg" borderRadius="lg" w="180px">
                <AdminPanel provider={provider} />
              </Box>
            )}
          </>
        )}
      </Box>
    </ChakraProvider>
  );
}
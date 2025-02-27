import { useEffect, useState } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";

const UserBalance = () => {
  const [balance, setBalance] = useState("0");

  useEffect(() => {
    const fetchBalance = async () => {
      if (typeof window !== "undefined" && window.ethereum) { // Ensure window.ethereum exists
        try {
          const provider = new ethers.BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();
          const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer); // Pass only ABI array
          
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
    <div className="p-6 bg-gray-800 rounded-md text-white">
      <h2 className="text-xl font-bold">Your Token Balance</h2>
      <p className="text-lg">{balance} Tokens</p>
    </div>
  );
};

export default UserBalance;

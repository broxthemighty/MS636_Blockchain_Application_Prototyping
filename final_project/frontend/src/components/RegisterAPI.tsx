import { useState } from "react";
import { ethers } from "ethers";
import React from "react";
import { CONTRACT_ADDRESS, ABI } from "../config";

const RegisterAPI = () => {
  const [name, setName] = useState("");
  const [pricePerRequest, setPricePerRequest] = useState("");
  const [subscriptionPrice, setSubscriptionPrice] = useState("");
  const [subscriptionDuration, setSubscriptionDuration] = useState("");

  const registerAPI = async () => {
    if (!window.ethereum) return alert("Please install MetaMask");

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
      alert("API Registered Successfully!");
    } catch (err) {
      console.error(err);
      alert("API registration failed!");
    }
  };

  return (
    <div className="p-6 bg-gray-800 rounded-md text-white">
      <h2 className="text-xl font-bold">Register API</h2>
      <input className="w-full my-2 p-2 bg-gray-700 rounded" type="text" placeholder="API Name" onChange={(e) => setName(e.target.value)} />
      <input className="w-full my-2 p-2 bg-gray-700 rounded" type="text" placeholder="Price Per Request (ETH)" onChange={(e) => setPricePerRequest(e.target.value)} />
      <input className="w-full my-2 p-2 bg-gray-700 rounded" type="text" placeholder="Subscription Price (ETH)" onChange={(e) => setSubscriptionPrice(e.target.value)} />
      <input className="w-full my-2 p-2 bg-gray-700 rounded" type="number" placeholder="Subscription Duration (Days)" onChange={(e) => setSubscriptionDuration(e.target.value)} />
      <button className="w-full p-2 bg-blue-500 rounded hover:bg-blue-600" onClick={registerAPI}>Register API</button>
    </div>
  );
};

export default RegisterAPI;

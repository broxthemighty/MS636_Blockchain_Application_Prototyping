import { useState } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import React from "react";

interface Props {
  provider: BrowserProvider;
}

export default function AdminPanel({ provider }: Props) {
  const [apiName, setApiName] = useState("");
  const [apiPrice, setApiPrice] = useState("");

  async function registerAPI() {
    if (!provider) return;
    const signer = await provider.getSigner();
    const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

    try {
      const tx = await contract.registerAPI(apiName, apiPrice);
      await tx.wait();
      alert("API registered successfully!");
    } catch (error) {
      console.error("Error registering API:", error);
    }
  }

  return (
  <div className="w-full max-w-lg bg-white shadow-md rounded-lg p-6 mt-4">
      <h2>Admin Panel</h2>
      <input type="text" value={apiName} onChange={(e) => setApiName(e.target.value)} placeholder="API Name" />
      <input type="number" value={apiPrice} onChange={(e) => setApiPrice(e.target.value)} placeholder="Price" />
      <button onClick={registerAPI}>Register API</button>
    </div>
  );
}

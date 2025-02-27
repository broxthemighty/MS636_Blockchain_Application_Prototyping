import { useState } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";

const PurchaseAPI = () => {
  const [apiId, setApiId] = useState("");
  const [requests, setRequests] = useState("");

  const purchaseAccess = async () => {
    if (!window.ethereum) return alert("Please install MetaMask");

    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

    try {
      const api = await contract.getAPI(apiId);
      const pricePerRequest = api[1];
      const totalCost = ethers.parseEther(pricePerRequest) * BigInt(requests);
      const tx = await contract.purchaseAPIAccess(apiId, requests, { value: totalCost });
      await tx.wait();
      alert("API Access Purchased!");
    } catch (err) {
      console.error(err);
      alert("Purchase Failed");
    }
  };

  return (
    <div className="p-6 bg-gray-800 rounded-md text-white">
      <h2 className="text-xl font-bold">Purchase API Access</h2>
      <input className="w-full my-2 p-2 bg-gray-700 rounded" type="number" placeholder="API ID" onChange={(e) => setApiId(e.target.value)} />
      <input className="w-full my-2 p-2 bg-gray-700 rounded" type="number" placeholder="Requests" onChange={(e) => setRequests(e.target.value)} />
      <button className="w-full p-2 bg-green-500 rounded hover:bg-green-600" onClick={purchaseAccess}>Buy Requests</button>
    </div>
  );
};

export default PurchaseAPI;

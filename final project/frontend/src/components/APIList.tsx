import { useState, useEffect } from "react";
import { BrowserProvider, Contract } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";
import React from "react";

interface API {
  id: number;
  name: string;
  pricePerRequest: number;
  totalPurchases: number;
  isActive: boolean;
}

interface Props {
  provider: BrowserProvider;
}

export default function APIList({ provider }: Props) {
  const [apis, setApis] = useState<API[]>([]);

  async function fetchAPIs() {
    if (!provider || !CONTRACT_ADDRESS) return;

    try {
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, ABI, signer);

      const apiCount = await contract.apiIdCounter();
      const fetchedAPIs: API[] = [];

      for (let i = 0; i < apiCount; i++) {
        const api = await contract.apis(i);
        fetchedAPIs.push({
          id: i,
          name: api.name,
          pricePerRequest: Number(api.pricePerRequest),
          totalPurchases: Number(api.totalPurchases),
          isActive: Boolean(api.isActive),
        });
      }

      setApis(fetchedAPIs);
    } catch (error) {
      console.error("Error fetching API list:", error);
    }
  }

  useEffect(() => {
    fetchAPIs();
    const interval = setInterval(fetchAPIs, 5000);
    return () => clearInterval(interval);
  }, [provider]);

  return (
    <div className="flex flex-col items-center w-full max-w-7xl p-4">
      <h2 className="text-3xl font-bold text-gray-800 text-center">Available APIs</h2>
  
      <button
        onClick={fetchAPIs}
        className="mb-4 px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 transition"
      >
        Refresh API List 🔄
      </button>
  
      {apis.length > 0 ? (
        <div className="flex flex-wrap justify-center gap-4 w-full max-w-7xl">
          {apis.map((api) => (
            <div
              key={api.id}
              className="bg-white rounded-lg shadow-md p-4 flex flex-col items-center justify-between w-64 h-44 border border-gray-300"
            >
              <p className="text-lg font-bold text-gray-800">{api.name}</p>
              <p className="text-md text-gray-600">💰 Price: {api.pricePerRequest} Tokens</p>
              <p className="text-md text-gray-600">📈 Purchases: {api.totalPurchases}</p>
              <p
                className={`text-md font-semibold ${
                  api.isActive ? "text-green-600" : "text-red-600"
                }`}
              >
                {api.isActive ? "🟢 Active" : "🔴 Inactive"}
              </p>
            </div>
          ))}
        </div>
      ) : (
        <p className="text-gray-600 text-center">No APIs found</p>
      )}
    </div>
  );  
}

import WalletConnector from "../components/WalletConnector";
import APIList from "../components/APIList";
import AdminPanel from "../components/AdminPanel";
import React from "react";

export default function Home({ provider }) {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen w-full bg-gray-100 p-4">
      <h1 className="text-4xl font-bold text-blue-600 mb-6 text-center">General API Marketplace</h1>

      <div className="w-full max-w-lg bg-white shadow-md rounded-lg p-6 mb-6">
        <WalletConnector />
      </div>

      <div className="w-full max-w-7xl">
        <APIList provider={provider} />
      </div>

      <div className="w-full max-w-lg bg-white shadow-md rounded-lg p-6 mt-6">
        <AdminPanel provider={provider} />
      </div>
    </div>
  );
}

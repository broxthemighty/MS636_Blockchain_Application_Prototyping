import "../styles/index.css";
import WalletConnector from "../components/WalletConnector";
import React from "react";

export default function MyApp({ Component, pageProps }) {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center">
      <WalletConnector />
      <Component {...pageProps} />
    </div>
  );
}

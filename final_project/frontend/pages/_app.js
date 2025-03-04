import WalletConnector from "../components/WalletConnector";
function MyApp({ Component, pageProps }) {
  return (
    <>
      <WalletConnector />
      <Component {...pageProps} />
    </>
  );
}
export default MyApp;

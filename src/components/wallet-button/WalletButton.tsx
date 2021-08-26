import { useEthers } from "@usedapp/core";

function WalletButton() {
  const { activateBrowserWallet, account } = useEthers();

  function handleConnectWallet() {
    console.log('Yay!')
    activateBrowserWallet();
  }

    return(
      <div>
          <button className="py-2 px-2 font-medium text-white bg-green-500 rounded hover:bg-green-400 transition duration-300" onClick={handleConnectWallet}>Connect Wallet</button>
        {account && <p>Account: {account}</p>}
      </div>
    );
}

export default WalletButton;

/* <>
<button className="py-2 px-2 font-medium text-white bg-green-500 rounded hover:bg-green-400 transition duration-300">Connect Wallet</button>
</> */
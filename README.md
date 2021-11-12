# FanPool

FanPool is a creator economy platform that allows fans to pool their crypto holdings for their favorite social media influencer, music artist, or any creator. 

The pooled crypto funds would be parked in a yield generating vehicle(we used Compound), with the yield profits going to the Creator.  The fans would be able to financially contribute to their favorite artists while their original investments remain untouched.  

Whenever the fans want to remove their funds from this pool they can do so. In exchange for this the Creators are suggested by the platform to reward the fans by providing NFT swags.

### Built With
* [Node.js]()
* [React.js](https://reactjs.org/)
* [Solidity]()
* [Hardhat]()
* [Ethers.js]()
* [TailwindCss](https://tailwindcss.com/)

<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

Setup ethereum network

   - Please skip this step if you want to use local network
   - Change line - `const NETWORK = LOCAL_NETWORK` to `const NETWORK = TEST_NETWORK` in `hardhat.config.js`
   

Configuring Alchemy API

   - Replace `YOUR_ALCHEMY_API_KEY` with your api key from alchemy in `.env` file
   - Replace `YOUR_WALLET_PRIVATE_KEY` with your wallet's private key from metamask wallet in `.env` file

## Running your app locally

1. Start your react frontend

   ```bash
   npm start
   ```

2. Start a hardhat node

   ```bash
   npx hardhat node
   ```

3. Connect hardhat node to Metamask

   Open Metamask > Select the network dropdown from the top left > Select `Custom RPC` and enter the following details:

   - Network Name: `<Enter a name for the network>`
   - New RPC URL: `http://127.0.0.1:8545`
   - Chain ID: `31337`

   Click save. You can use this network to connect to the local hardhat node.

4. Connect your local hardhat account to Metamask for making transactions
   - After running `npx hardhat node` you will see a list of 20 addresses logged in the terminal
   - To configure an account copy its private key from the terminal (i.e the text after `Private Key:`)
   - Open Metamask > Click the account icon on top right > Import Account > Paste the private key you just copied > click Import
   - You should now have the account connected with 10000 ETH

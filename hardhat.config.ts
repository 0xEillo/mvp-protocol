import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";

const GOERLI_API_KEY = process.env.GOERLI_API_KEY;
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;

// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "KEY" with its key
const ALCHEMY_API_KEY = "KEY";

// Replace this private key with your Goerli account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const ROPSTEN_PRIVATE_KEY = "YOUR ROPSTEN PRIVATE KEY";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
      {
        version: "0.8.10",
      },
    ],
  },
  networks: {
    goerli: {
      url: GOERLI_API_KEY,
      accounts: [`${GOERLI_PRIVATE_KEY}`],
    },
  },
};

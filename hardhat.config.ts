import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";

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
  // networks: {
  //   ropsten: {
  //     url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
  //     accounts: [`${ROPSTEN_PRIVATE_KEY}`],
  //   },
  // },
};

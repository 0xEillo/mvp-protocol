import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";

const GOERLI_API_KEY = process.env.GOERLI_API_KEY;
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;

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

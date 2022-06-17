import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import { GOERLI_API_KEY, GOERLI_PRIVATE_KEY } from "./secrets";

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

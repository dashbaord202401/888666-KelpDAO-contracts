import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-solhint";
import "@nomicfoundation/hardhat-foundry";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.21",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
      url: `https://eth-goerli.nodereal.io/v1/${process.env.API_KEY_NODE_REAL}`,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY ?? ""],
    },
    mainnet: {
      url: `https://eth-mainnet.nodereal.io/v1/${process.env.API_KEY_NODE_REAL}`,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY ?? ""],
    },
  },
  etherscan: {
    apiKey: {
      goerli: `${process.env.GOERLI_ETHERSCAN_API_KEY}`,
      mainnet: `${process.env.MAINNET_ETHERSCAN_API_KEY}`,
    },
  },
};

export default config;

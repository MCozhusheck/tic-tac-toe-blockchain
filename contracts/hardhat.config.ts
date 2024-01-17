import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "@typechain/hardhat";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import "dotenv/config";

const { PRIVATE_KEY } = process.env;

console.log(PRIVATE_KEY);

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      accounts: [
        {
          privateKey: PRIVATE_KEY as string,
          balance: "100000000000000000",
        },
      ],
    },
  },
};

export default config;

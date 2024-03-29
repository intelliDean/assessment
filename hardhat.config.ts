import {HardhatUserConfig} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config();

const {URL, KEY, EScanAPI} = process.env;

const config: HardhatUserConfig = {
    solidity: "0.8.24",
    networks: {
        sepolia: {
            url: URL,
            accounts: [`0x${KEY}`]
        }
    },
    etherscan:{
    apiKey: EScanAPI
   }
};

export default config;
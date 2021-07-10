require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");

const fs = require("fs");
let credentials = require("./credentials.example.json");
if (fs.existsSync("./credentials.json")) {
  credentials = require("./credentials.json");
}

module.exports = {
  networks: {
    mainnet: {
      url: credentials.mainnet.providerUrl || "",
      accounts: { mnemonic: credentials.mainnet.mnemonic || "" },
    },
  },
  solidity: {
    version: "0.8.6",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};

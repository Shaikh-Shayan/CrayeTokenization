var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "army broccoli awful phone coach scorpion manage outdoor alert amount dance media";

const solcStable = {
  version: '^0.8.0',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      network_id: "*",
      port: 7575,
      // gas: 0xfffffffffff,
      // gasPrice: 20000000000,
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/d275ac1912444bd486deac61b35167b9");
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
    }
  },

  compilers: {
    solc: solcStable,
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      outputFile: './gas-report'
    },
  },
  plugins: ['solidity-coverage'],
};
require('@nomiclabs/hardhat-waffle');
require('dotenv').config();
const fs = require('fs');

//metamask wallet private key
const privateKey = fs.readFileSync('.secret').toString();

const projectId = process.env.INFURA_PROJECT_ID;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  //configure the different networks
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mainnet.infura.io/v3/${projectId}`,
      accounts: [privateKey],
    },
    mainnet: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey],
    },
  },
  solidity: '0.8.4',
};

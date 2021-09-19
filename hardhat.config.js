require('@nomiclabs/hardhat-waffle');
require('dotenv').config();
const fs = require('fs');

//metamask wallet private key
const privateKey = process.env.INFURA_PRIVATE_KEY;

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
      url: `https://polygon-mumbai.infura.io/v3/${projectId.toString()}`,
      accounts: [privateKey.toString()],
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${projectId.toString()}`,
      accounts: [privateKey.toString()],
    },
  },
  solidity: '0.8.4',
};

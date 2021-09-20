require('@nomiclabs/hardhat-waffle');
require('dotenv').config();
// const fs = require('fs');

//metamask wallet private key
const privateKey = process.env.PRIVATE_KEY;

const projectId = process.env.INFURA_PROJECT_ID;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  //configure the different networks
  networks: {
    hardhat: {
      chainId: 80001,
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey.toString().trim()],
    },
    // mainnet: {
    //   url: `https://polygon-mainnet.infura.io/v3/${projectId}`,
    //   accounts: [privateKey],
    // },
  },
  solidity: '0.8.4',
};

//

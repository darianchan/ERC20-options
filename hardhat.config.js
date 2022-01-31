require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;
module.exports = {
   solidity: "0.8.9"
    // defaultNetwork: "rinkeby",
    // networks: {
    //     hardhat: {
    //       chainId: 1337
    //     },
    //     rinkeby: {
    //       url: API_URL,
    //       accounts: [`0x${PRIVATE_KEY}`]
    //     }
    // },
}
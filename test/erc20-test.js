const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("erc20-options", function () {
  let accounts;
  let OptionsContractFactory;
  let optionsContract;

  beforeEach(async function() {
    accounts = await ethers.getSigners();

    OptionsContractFactory = await ethers.getContractFactory("OptionsContract");
    optionsContract = await OptionsContractFactory.deploy("ETH/USD", "oETH", accounts[0].address, "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e");

    await optionsContract.deployed();
  })
});

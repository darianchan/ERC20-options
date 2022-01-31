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

    // add 10 eth to ensure option liquidity
    optionsContract.addLiquidity({value: ethers.utils.parseEther("10")});
  })

  it("should allow a user to mint collateral", async function() {
    await optionsContract.mintOption(ethers.utils.parseEther("1.5"), ethers.utils.parseEther(".1"), 3600 * 24 * 7, {value: ethers.utils.parseEther("1.6")}) 
    expect(await optionsContract.balanceOf(accounts[0].address)).to.eq(ethers.utils.parseEther(".1"))
  })
});

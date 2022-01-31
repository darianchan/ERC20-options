const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("erc20-options", function () {
  let accounts;
  let OptionsContractFactory;
  let optionsContract;

  beforeEach(async function () {
    accounts = await ethers.getSigners();

    OptionsContractFactory = await ethers.getContractFactory("OptionsContract");
    optionsContract = await OptionsContractFactory.deploy(
      "ETH/USD",
      "oETH",
      accounts[0].address,
      "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e"
    );

    await optionsContract.deployed();

    // add 10 eth to ensure option liquidity
    optionsContract.addLiquidity({ value: ethers.utils.parseEther("10") });
  });

  describe("mint option", function() {
    it("should allow a user to mint an erc20 option with locked in collateral", async function () {
      await optionsContract.mintOption(
        ethers.utils.parseEther("1.5"),
        ethers.utils.parseEther(".1"),
        3600 * 24 * 7,
        { value: ethers.utils.parseEther("1.6") }
      );
      expect(await optionsContract.balanceOf(accounts[0].address)).to.eq(
        ethers.utils.parseEther(".1")
      );
    });
  
    it("should revert if a user tries to mint an optoin without locked in collateral", async function () {
      await expect(
        optionsContract.mintOption(
          ethers.utils.parseEther("1.5"),
          ethers.utils.parseEther(".1"),
          3600 * 24 * 7
        )
      ).to.be.reverted;
    });
  })

  describe("exercise option", function() {
    beforeEach(async function() {
      // first mint an option
      await optionsContract.mintOption(
        ethers.utils.parseEther("1.5"),
        ethers.utils.parseEther(".1"),
        86400 * 7,
        { value: ethers.utils.parseEther("1.6") }
      );
    })

    it("should allow a user who owns an erc20 to exercise", async function() {
      // increase time by 7 days so option expires
      await ethers.provider.send("evm_increaseTime", [86400 * 7]);
      await ethers.provider.send("evm_mine");

      await optionsContract.exerciseOption(1);
    })
  })
});

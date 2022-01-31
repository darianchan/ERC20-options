const { ethers } = require("hardhat");

async function main() {
  // deploy the coveredCall contract
  const optionsContractFactory = await ethers.getContractFactory("OptionsContract")
  const optionsContract = await optionsContractFactory.deploy("ETH/USD", "oETH", "0x3e6a2B9D58314D81234465eE778CF2794dA4E430", "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e");
  console.log("test nft deployed to:", optionsContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

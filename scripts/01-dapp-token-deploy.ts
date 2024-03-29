import { ethers } from "hardhat";

async function main() {
  const DappToken = await ethers.getContractFactory("DappToken");
  const dappToken = await DappToken.deploy();

  await dappToken.deployed();

  console.log(`DappToken deployed to ${dappToken.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

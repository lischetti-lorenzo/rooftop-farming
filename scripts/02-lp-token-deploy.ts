import { ethers } from "hardhat";

async function main() {
  const LpToken = await ethers.getContractFactory("LPToken");
  const lpToken = await LpToken.deploy();

  await lpToken.deployed();

  console.log(`LPToken deployed to ${lpToken.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

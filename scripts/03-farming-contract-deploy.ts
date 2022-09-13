import { ethers } from "hardhat";

async function main() {
  const dappTokenAddress = '0x3f70e893817BCFCecd2B53dD92F52b929c2179a3';
  const lpTokenAddress = '0x3954ad366cA65588096D3Df141268453fAA5F511';
  const TokenFarm = await ethers.getContractFactory("TokenFarm");
  const tokenFarm = await TokenFarm.deploy(dappTokenAddress, lpTokenAddress);

  await tokenFarm.deployed();

  console.log(`TokenFarm deployed to ${tokenFarm.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

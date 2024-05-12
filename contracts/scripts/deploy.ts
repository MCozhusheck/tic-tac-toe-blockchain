import { ethers } from "hardhat";
import { saveDeployedContracts } from "./utils";
import { Battleship, MerkleTreeValidator } from "../typechain-types";

async function main() {
  const validator = await ethers.deployContract("MerkleTreeValidator", []);
  await validator.waitForDeployment();

  const battleshipFactory = await ethers.deployContract("BattleshipFactory", [
    validator.getAddress(),
  ]);
  await battleshipFactory.waitForDeployment();

  saveDeployedContracts("sepolia", {
    validator: await validator.getAddress(),
    battleshipFactory: await battleshipFactory.getAddress(),
  });
  console.log("MerkleTreeValidator deployed to:", await validator.getAddress());
  console.log(
    "BattleshipFactory deployed to:",
    await battleshipFactory.getAddress()
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

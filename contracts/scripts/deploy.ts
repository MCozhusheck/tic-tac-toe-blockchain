import { ethers } from "hardhat";

async function main() {
  const validator = await ethers.deployContract("MerkleTreeValidator", []);

  await validator.waitForDeployment();

  const seed = Math.floor(Math.random() * 1000000000);
  const player1ShipsPositions = [
    3, 5, 7, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ];
  const player1Board = await validator.generateBoard(
    player1ShipsPositions,
    seed
  );
  const player1BoardHash = await validator.hashBoard([...player1Board]);
  const player1RootHash = await validator.getTreeRootHash([
    ...player1BoardHash,
  ]);

  const stakeAmount = await validator.STAKE_AMOUNT();
  const battleship = await ethers.deployContract(
    "Battleship",
    [validator.getAddress(), player1RootHash],
    { value: stakeAmount }
  );

  await battleship.waitForDeployment();

  console.log("MerkleTreeValidator deployed to:", await validator.getAddress());
  console.log("Battleship deployed to:", await battleship.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

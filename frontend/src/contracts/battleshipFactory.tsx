"use client";

import { useAccount, useReadContract, useWriteContract } from "wagmi";
import sepoliaDeploy from "../../../contracts/deployed-contracts/sepolia.json";
import BattleshipFactory from "../../../contracts/artifacts/src/utils/BattleshipFactory.sol/BattleshipFactory.json";

export const useDeployBoard = () => {
  const { data: hash, isPending, error, writeContract } = useWriteContract();

  const deploy = async (playerBoardRootHash: string, stakeAmount: bigint) =>
    writeContract({
      address: sepoliaDeploy.battleshipFactory as `0x${string}`,
      abi: BattleshipFactory.abi,
      functionName: "createBattleship",
      args: [playerBoardRootHash],
      value: stakeAmount,
    });

  return { hash, isPending, error, deploy };
};

export const useGetDeployedBoards = () => {
  const { address } = useAccount();
  const { data, ...rest } = useReadContract({
    abi: BattleshipFactory.abi,
    address: sepoliaDeploy.battleshipFactory as `0x${string}`,
    functionName: "getDeployedBattleships",
    args: [address],
  });
  const deployedBoards = data as string[] | undefined;
  return {
    deployedBoards,
    ...rest,
  };
};

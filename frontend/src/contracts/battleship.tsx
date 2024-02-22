"use client";

import { useReadContract } from "wagmi";
import sepoliaDeploy from "../../../contracts/deployed-contracts/sepolia.json";
import { abi } from "../../../contracts/artifacts/src/Battleship.sol/Battleship.json";

export const useGetPlayer1 = (battleshipAddress: `0x${string}`) => {
  const { data, ...rest } = useReadContract({
    abi,
    address: battleshipAddress,
    functionName: "player1",
    args: [],
  });
  const player1Address = data as `0x${string}`;
  return { player1Address, ...rest };
};

export const useGetPlayer2 = (battleshipAddress: `0x${string}`) => {
  const { data, ...rest } = useReadContract({
    abi,
    address: battleshipAddress,
    functionName: "player2",
    args: [],
  });
  const player2Address = data as `0x${string}`;
  return { player2Address, ...rest };
};

export const useGetPlayerHitPositions = (
  battleshipAddress: `0x${string}`,
  player: `0x${string}`
) => {
  const { data, ...rest } = useReadContract({
    abi,
    address: battleshipAddress,
    functionName: "scoredHits",
    args: [player],
  });
  const hitPositions = data as boolean[] | undefined;
  return { hitPositions, ...rest };
};

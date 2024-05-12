"use client";

import { useReadContract } from "wagmi";
import Battleship from "../../../contracts/artifacts/src/Battleship.sol/Battleship.json";

export enum GameState {
  WAITING_FOR_USER_2,
  PLAYER_ATTACKS,
  PLAYER_RESPONDS,
  WAITING_FOR_PROOFS,
  WAITING_FOR_PRIZE_CLAIM,
  FINISHED,
}

export const useGetPlayer1 = (battleshipAddress: `0x${string}`) => {
  const { data, ...rest } = useReadContract({
    abi: Battleship.abi,
    address: battleshipAddress,
    functionName: "player1",
    args: [],
  });
  const player1Address = data as `0x${string}`;
  return { player1Address, ...rest };
};

export const useGetPlayer2 = (battleshipAddress: `0x${string}`) => {
  const { data, ...rest } = useReadContract({
    abi: Battleship.abi,
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
    abi: Battleship.abi,
    address: battleshipAddress,
    functionName: "getHitPostions",
    args: [player],
  });
  const hitPositions = data as boolean[] | undefined;
  return { hitPositions, ...rest };
};

export const useGetCurrentState = (battleshipAddress: `0x${string}`) => {
  const { data, ...rest } = useReadContract({
    abi: Battleship.abi,
    address: battleshipAddress,
    functionName: "state",
    args: [],
  });
  const response = data as number | undefined;
  const state = response !== undefined ? GameState[response] : undefined;
  return { state, ...rest };
};

export const useGetPlayerRootHash = (
  battleshipAddress: `0x${string}`,
  playerAddress: `0x${string}` | undefined
) => {
  const { data, ...rest } = useReadContract({
    abi: Battleship.abi,
    address: battleshipAddress,
    functionName: "rootHash",
    args: [playerAddress],
  });
  const rootHash = data as string;
  return { rootHash, ...rest };
};

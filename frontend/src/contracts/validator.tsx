"use client";

import sepoliaDeploy from "../../../contracts/deployed-contracts/sepolia.json";
import { abi } from "../../../contracts/artifacts/src/utils/MerkleTreeValidator.sol/MerkleTreeValidator.json";
import { readContract } from "wagmi/actions";
import { config } from "@/config";

const address = sepoliaDeploy.validator as `0x${string}`;

export const generateBoard = (board: number[], salt: number) =>
  readContract(config, {
    abi,
    address,
    functionName: "generateBoard",
    args: [board, salt],
  }) as Promise<string[]>;

export const hashBoard = (board: string[]) =>
  readContract(config, {
    abi,
    address,
    functionName: "hashBoard",
    args: [board],
  }) as Promise<string[]>;

export const getBoardRootHash = (board: string[]) =>
  readContract(config, {
    abi,
    address,
    functionName: "getTreeRootHash",
    args: [board],
  }) as Promise<string>;

export const getStakeAmount = () =>
  readContract(config, {
    abi,
    address,
    functionName: "STAKE_AMOUNT",
    args: [],
  }) as Promise<bigint>;

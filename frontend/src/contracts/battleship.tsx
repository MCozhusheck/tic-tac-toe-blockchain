"use client";

import { useReadContract } from "wagmi";
import hardhatDeploy from "../../../contracts/deployed-contracts/hardhat.json";
import { abi as battleshipAbi } from "../../../contracts/artifacts/src/Battleship.sol/Battleship.json";

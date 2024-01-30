"use client";

import { useReadContract } from "wagmi";
import hardhatDeploy from "../../../contracts/deployed-contracts/hardhat.json";
import { abi as validatorpAbi } from "../../../contracts/artifacts/src/utils/MerkleTreeValidator.sol/MerkleTreeValidator.json";

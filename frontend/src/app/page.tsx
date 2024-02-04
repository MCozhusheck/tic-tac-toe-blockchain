"use client";

import { BoardContext } from "@/context";
import { useContext, useState } from "react";
import { BattleshipBoard } from "./components/BattleshipBoard";
import {
  generateBoard,
  getBoardRootHash,
  getStakeAmount,
  hashBoard,
} from "@/contracts/validator";
import {
  getDeployedBoards,
  useDeployBoard,
} from "@/contracts/battleshipFactory";
import { useAccount } from "wagmi";

function App() {
  const { board, setBoard } = useContext(BoardContext);
  const { hash, isPending, error, deploy } = useDeployBoard();
  const { address } = useAccount();

  const onCellClick = (index: number) => {
    const newBoard = [...board];
    if (newBoard[index] === "empty") {
      newBoard[index] = "ship";
    } else {
      newBoard[index] = "empty";
    }
    setBoard(newBoard);
  };

  const validateBoard = (board: string[]) => {
    const shipCount = board.filter((cell) => cell === "ship").length;
    return shipCount === 4;
  };

  const createBoard = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateBoard(board)) {
      console.error("Invalid board");
      return;
    }
    const initIndices: number[] = [];
    const indices = board.reduce((acc, cell, index) => {
      if (cell === "ship") {
        acc.push(index);
      }
      return acc;
    }, initIndices);
    // TODO fix contracts to accept only 4 element array
    const fixedIndices = indices.concat(Array.from({ length: 12 }, () => 0));
    const privateBoard = await generateBoard(fixedIndices, 123);
    const publicBoard = await hashBoard(privateBoard);
    const boardRootHash = await getBoardRootHash(publicBoard);
    const stakeAmount = await getStakeAmount();
    await deploy(boardRootHash, stakeAmount);
  };

  const dupa = async () => {
    const boards = await getDeployedBoards(address);
    console.log(boards);
  };

  return (
    <div>
      <w3m-button />
      <BattleshipBoard board={board} onCellClick={onCellClick} />
      <form>
        <button type="submit" onClick={createBoard}>
          Submit
        </button>
      </form>
    </div>
  );
}

export default App;

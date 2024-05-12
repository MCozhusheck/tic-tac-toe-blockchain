"use client";

import { useState } from "react";
import { BattleshipBoard, emptyBoard } from "./components/BattleshipBoard";
import {
  generateBoard,
  getBoardRootHash,
  getStakeAmount,
  hashBoard,
} from "@/contracts/validator";
import {
  useDeployBoard,
  useGetDeployedBoards,
} from "@/contracts/battleshipFactory";
import Link from "next/link";

function getRandomInt() {
  return Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
}

function App() {
  const [board, setBoard] = useState(emptyBoard);
  const { isPending, deploy } = useDeployBoard();
  const { refetch: refetchBoards, deployedBoards } = useGetDeployedBoards();

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
    const salt = getRandomInt();
    const privateBoard = await generateBoard(fixedIndices, salt);
    const publicBoard = await hashBoard(privateBoard);
    const boardRootHash = await getBoardRootHash(publicBoard);
    const stakeAmount = await getStakeAmount();
    await deploy(boardRootHash, stakeAmount);
    localStorage.setItem(boardRootHash, JSON.stringify(privateBoard));
    refetchBoards();
  };

  return (
    <div className="flex-auto flex-col">
      <div className="pt-6 flex content-center justify-center">
        <w3m-button />
      </div>
      <div className="pt-6 flex content-center justify-center">
        <BattleshipBoard board={board} onCellClick={onCellClick} />
      </div>
      <div className="pt-6 flex content-center justify-center">
        <form>
          <button type="submit" onClick={createBoard}>
            {isPending ? "Deploying..." : "Submit"}
          </button>
        </form>
      </div>
      <div className="flex flex-col flex-wrap content-center justify-center">
        {deployedBoards?.map((boardAddress) => (
          <div className="pt-1" key={boardAddress}>
            <Link href={boardAddress}>{boardAddress}</Link>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;

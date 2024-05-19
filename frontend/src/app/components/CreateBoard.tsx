"use client";

import { useState } from "react";
import { BattleshipBoard, emptyBoard } from "./BattleshipBoard";
import {
  generateBoard,
  getBoardRootHash,
  hashBoard,
} from "@/contracts/validator";
import { getRandomInt } from "@/utils/math";

type CreateBoardProps = {
  onHashCalculated: (boardRootHash: string) => Promise<void>;
  disabled: boolean;
  isPending: boolean;
};

export function CreateBoard({
  onHashCalculated,
  disabled,
  isPending,
}: CreateBoardProps) {
  const [board, setBoard] = useState(emptyBoard);

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
    await onHashCalculated(boardRootHash);
    localStorage.setItem(boardRootHash, JSON.stringify(privateBoard));
  };

  return (
    <div className="flex-auto flex-col">
      <div className="pt-6 flex content-center justify-center">
        <BattleshipBoard board={board} onCellClick={onCellClick} />
      </div>
      <div className="pt-6 flex content-center justify-center">
        <form>
          <button
            type="submit"
            disabled={disabled}
            className={`${disabled ? "opacity-50 cursor-not-allowed" : ""}`}
            onClick={createBoard}
          >
            {isPending ? "Waiting..." : "Submit"}
          </button>
        </form>
      </div>
    </div>
  );
}

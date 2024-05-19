"use client";

import {
  GameState,
  useGetCurrentState,
  useGetPlayer1,
  useGetPlayer2,
  useJoinTheGame,
} from "@/contracts/battleship";
import { useParams } from "next/navigation";
import { useAccount } from "wagmi";
import { zeroAddress } from "viem";
import { useState } from "react";
import { BattleshipBoard, emptyBoard } from "@/app/components/BattleshipBoard";
import {
  generateBoard,
  getBoardRootHash,
  getStakeAmount,
  hashBoard,
} from "@/contracts/validator";

function getRandomInt() {
  return Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
}

function App() {
  const slug = useParams();
  const boardAddress = slug.boardAddress as `0x${string}`;

  const [board, setBoard] = useState(emptyBoard);
  const { address } = useAccount();
  const { isPending, error, join } = useJoinTheGame(boardAddress);
  const { state } = useGetCurrentState(boardAddress);

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

  const canJoin =
    state !== undefined ? state === GameState.WAITING_FOR_USER_2 : false;

  const joinTheGame = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateBoard(board)) {
      console.error("Invalid board");
      return;
    }
    if (!canJoin) {
      console.error("Cannot join the game");
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
    await join(boardRootHash, stakeAmount);
    localStorage.setItem(boardRootHash, JSON.stringify(privateBoard));
    isPending && console.log("Pending");
  };

  return (
    <div>
      <div className="pt-6 flex content-center justify-center">
        <BattleshipBoard board={board} onCellClick={onCellClick} />
      </div>
      <div className="pt-6 flex content-center justify-center">
        <form>
          <button
            type="submit"
            onClick={joinTheGame}
            disabled={!canJoin}
            className={`${!canJoin ? "opacity-50 cursor-not-allowed" : ""}`}
          >
            {isPending ? "Joining..." : "Submit"}
          </button>
        </form>
      </div>
    </div>
  );
}

export default App;

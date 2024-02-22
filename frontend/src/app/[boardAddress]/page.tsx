"use client";

import { useParams } from "next/navigation";
import { useState } from "react";
import { BattleshipBoard, emptyBoard } from "../components/BattleshipBoard";
import {
  useGetPlayer1,
  useGetPlayer2,
  useGetPlayerHitPositions,
} from "@/contracts/battleship";

const createBoardFromHitPositions = (hitPositions: boolean[]) => {
  const board = emptyBoard.slice();
  for (let i = 0; i < hitPositions.length; i++) {
    if (hitPositions[i]) {
      board[i] = "hit";
    }
  }
  return board;
};

function App() {
  const slug = useParams();
  const boardAddress = slug.boardAddress as `0x${string}`;

  const [enemyBoard, setEnemyBoard] = useState(emptyBoard);
  const [playerBoard, setPlayerBoard] = useState(emptyBoard);
  const { player1Address } = useGetPlayer1(boardAddress);
  const { player2Address } = useGetPlayer2(boardAddress);
  const { hitPositions: player1HitPositions } = useGetPlayerHitPositions(
    boardAddress,
    player1Address
  );
  const { hitPositions: player2HitPositions } = useGetPlayerHitPositions(
    boardAddress,
    player2Address
  );
  console.log(player1HitPositions, player2HitPositions);

  const player1Board = createBoardFromHitPositions(player1HitPositions || []);
  const player2Board = createBoardFromHitPositions(player2HitPositions || []);

  const onEnemyCellClick = (index: number) => {
    // TODO: fetch current game state from contract to decide if this is a valid move
    console.log(`Clicked enemy cell ${index}`);
  };

  const onPlayerCellClick = (index: number) => {
    // TODO: same as above
    console.log(`Clicked player cell ${index}`);
  };

  return (
    <div className="flex-auto flex-col">
      <div className="pt-6 flex content-center justify-center">
        <BattleshipBoard board={player1Board} onCellClick={onEnemyCellClick} />
      </div>
      <div className="pt-6 flex content-center justify-center">
        <BattleshipBoard board={player2Board} onCellClick={onPlayerCellClick} />
      </div>
    </div>
  );
}

export default App;

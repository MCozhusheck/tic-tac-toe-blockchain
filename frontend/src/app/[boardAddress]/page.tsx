"use client";

import { useParams } from "next/navigation";
import { useEffect, useState } from "react";
import { BattleshipBoard, emptyBoard } from "../components/BattleshipBoard";
import {
  useGetCurrentState,
  useGetPlayer1,
  useGetPlayer2,
  useGetPlayerHitPositions,
  useGetPlayerRootHash,
} from "@/contracts/battleship";
import { useAccount } from "wagmi";

const createBoardFromHitPositions = (hitPositions: boolean[]) => {
  const board = emptyBoard.slice();
  for (let i = 0; i < hitPositions.length; i++) {
    if (hitPositions[i]) {
      board[i] = "hit";
    }
  }
  return board;
};

const readBoardFromLocalStorage = (rootHash: string | undefined) => {
  if (!rootHash) {
    return [];
  }
  const board = localStorage.getItem(rootHash);
  if (!board) {
    return [];
  }
  console.log(`Read board from local storage: ${board}`);
  return JSON.parse(board);
};

function App() {
  const slug = useParams();
  const boardAddress = slug.boardAddress as `0x${string}`;

  const { address } = useAccount();
  const [enemyBoard, setEnemyBoard] = useState(emptyBoard);
  const [playerBoard, setPlayerBoard] = useState(emptyBoard);
  const [enemyPrivateBoard, setEnemyPrivateBoard] = useState<string[]>([]);
  const [playerPrivateBoard, setPlayerPrivateBoard] = useState<string[]>([]);
  const { state } = useGetCurrentState(boardAddress);
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
  const { rootHash: player1RootHash } = useGetPlayerRootHash(
    boardAddress,
    player1Address
  );
  const { rootHash: player2RootHash } = useGetPlayerRootHash(
    boardAddress,
    player2Address
  );
  useEffect(() => {
    setEnemyPrivateBoard(readBoardFromLocalStorage(player1RootHash));
    setPlayerBoard(readBoardFromLocalStorage(player2RootHash));
  }, [player1RootHash, player2RootHash]);

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
    <div>
      <p className="text-center pt-6">Player 1 Address: {player1Address}</p>
      <div className="flex-auto flex-col">
        <div className="pt-6 flex content-center justify-center">
          <BattleshipBoard
            board={player1Board}
            onCellClick={onEnemyCellClick}
          />
        </div>
        <p className="text-center pt-6">Player 2 Address: {player2Address}</p>
        <div className="pt-6 flex content-center justify-center">
          <BattleshipBoard
            board={player2Board}
            onCellClick={onPlayerCellClick}
          />
        </div>
      </div>
    </div>
  );
}

export default App;

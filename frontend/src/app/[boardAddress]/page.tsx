"use client";

import { useParams } from "next/navigation";
import { useState } from "react";
import { BattleshipBoard, emptyBoard } from "../components/BattleshipBoard";

function App() {
  const slug = useParams();
  const [enemyBoard, setEnemyBoard] = useState(emptyBoard);
  const [playerBoard, setPlayerBoard] = useState(emptyBoard);

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
        <BattleshipBoard board={enemyBoard} onCellClick={onEnemyCellClick} />
      </div>
      <div className="pt-6 flex content-center justify-center">
        <BattleshipBoard board={playerBoard} onCellClick={onPlayerCellClick} />
      </div>
    </div>
  );
}

export default App;

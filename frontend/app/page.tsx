import Image from "next/image";
import { BattleshipBoard } from "./components/Battleship";
import type { Cell } from "./components/Cell";

export default function Home() {
  const mockBoard: Cell[] = [
    "hit",
    "miss",
    "ship",
    "empty",
    "hit",
    "miss",
    "ship",
    "empty",
    "hit",
    "miss",
    "ship",
    "empty",
    "hit",
    "miss",
    "ship",
    "empty",
  ];

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <BattleshipBoard board={mockBoard} />
    </main>
  );
}

import React from "react";
import { Cell } from "./Cell";

export const BattleshipBoard = ({ board }: { board: Cell[] }) => {
  return (
    <div className="grid grid-cols-4 gap-4">
      {board.map((cell, index) => (
        <div
          key={index}
          className="w-16 h-16 border border-gray-300 bg-gray-100 flex items-center justify-center"
        >
          <Cell type={cell} />
        </div>
      ))}
    </div>
  );
};

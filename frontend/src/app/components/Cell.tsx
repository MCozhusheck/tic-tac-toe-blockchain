import React from "react";

export type Cell = "hit" | "miss" | "ship" | "empty";

export const Cell = ({ type }: { type: Cell }) => {
  const cellColor = () => {
    switch (type) {
      case "hit":
        return "bg-red-500";
      case "miss":
        return "bg-gray-500";
      case "ship":
        return "bg-blue-500";
      case "empty":
        return "bg-gray-100";
    }
  };

  return (
    <div
      className={`w-16 h-16 border border-gray-300 flex items-center justify-center ${cellColor()}`}
    >
      <div className="text-black">{type}</div>
    </div>
  );
};

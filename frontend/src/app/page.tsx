"use client";

import { getStakeAmount } from "@/contracts/validator";
import {
  useDeployBoard,
  useGetDeployedBoards,
} from "@/contracts/battleshipFactory";
import Link from "next/link";
import { CreateBoard } from "./components/CreateBoard";

function App() {
  const { isPending, deploy } = useDeployBoard();
  const { refetch: refetchBoards, deployedBoards } = useGetDeployedBoards();

  const deployBoard = async (boardRootHash: string) => {
    const stakeAmount = await getStakeAmount();
    await deploy(boardRootHash, stakeAmount);
    refetchBoards();
  };

  return (
    <div className="flex-auto flex-col">
      <div className="pt-6 flex content-center justify-center">
        <w3m-button />
      </div>
      <CreateBoard
        onHashCalculated={deployBoard}
        disabled={false}
        isPending={isPending}
      />
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

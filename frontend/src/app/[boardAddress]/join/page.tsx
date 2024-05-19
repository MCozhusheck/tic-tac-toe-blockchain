"use client";

import {
  GameState,
  useGetCurrentState,
  useJoinTheGame,
} from "@/contracts/battleship";
import { useParams, useRouter } from "next/navigation";
import { CreateBoard } from "@/app/components/CreateBoard";
import { getStakeAmount } from "@/contracts/validator";

function App() {
  const slug = useParams();
  const boardAddress = slug.boardAddress as `0x${string}`;

  const { isPending, join, isSuccess } = useJoinTheGame(boardAddress);
  const { state } = useGetCurrentState(boardAddress);
  const router = useRouter();

  const canJoin =
    state !== undefined ? state === GameState.WAITING_FOR_USER_2 : false;

  const joinTheGame = async (boardRootHash: string) => {
    const stakeAmount = await getStakeAmount();
    await join(boardRootHash, stakeAmount);
  };

  return (
    <div>
      <CreateBoard
        onHashCalculated={joinTheGame}
        disabled={!canJoin}
        isPending={isPending}
      />
      {isSuccess && (
        <div className="pt-6 flex content-center justify-center flex-col">
          <p>You have successfully joined the game!</p>
          <button onClick={() => router.push(`/${boardAddress}`)}>
            Go to Game
          </button>
        </div>
      )}
    </div>
  );
}

export default App;

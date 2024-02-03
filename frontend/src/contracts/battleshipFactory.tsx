"use client";

import {
  BaseError,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";
import sepoliaDeploy from "../../../contracts/deployed-contracts/sepolia.json";
import { abi } from "../../../contracts/artifacts/src/utils/BattleshipFactory.sol/BattleshipFactory.json";

export function DeployBattleship({
  playerBoardRootHash,
}: {
  playerBoardRootHash: string;
}) {
  const { data: hash, isPending, error, writeContract } = useWriteContract();

  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    writeContract({
      address: sepoliaDeploy.battleshipFactory as `0x${string}`,
      abi,
      functionName: "createBattleship",
      args: [playerBoardRootHash],
    });
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  return (
    <form onSubmit={submit}>
      <button disabled={isPending} type="submit">
        {isPending ? "Start new game" : "Deploying..."}
      </button>
      {isConfirming && <div>Waiting for confirmation...</div>}
      {isConfirmed && <div>Transaction confirmed.</div>}
      {error && (
        <div>Error: {(error as BaseError).shortMessage || error.message}</div>
      )}
    </form>
  );
}

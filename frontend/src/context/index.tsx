"use client";

import React, { ReactNode, createContext } from "react";
import { config, projectId } from "@/config";
import { createWeb3Modal } from "@web3modal/wagmi/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { State, WagmiProvider } from "wagmi";
import { Cell } from "@/app/components/Cell";

// Setup queryClient
const queryClient = new QueryClient();

if (!projectId) throw new Error("Project ID is not defined");

// Create modal
createWeb3Modal({
  wagmiConfig: config,
  projectId,
  enableAnalytics: true, // Optional - defaults to your Cloud configuration
});

const initBoard = Array.from({ length: 16 }, () => "empty" as Cell);
type BoardContextType = {
  board: Cell[];
  setBoard: (board: Cell[]) => void;
};
export const BoardContext = createContext<BoardContextType>({
  board: initBoard,
  setBoard: (board: Cell[]) => {},
});

function BoardContextProvider({ children }: { children: ReactNode }) {
  const [board, setBoard] = React.useState(initBoard);
  return (
    <BoardContext.Provider value={{ board, setBoard }}>
      {children}
    </BoardContext.Provider>
  );
}

export function ContextProvider({
  children,
  initialState,
}: {
  children: ReactNode;
  initialState?: State;
}) {
  return (
    <WagmiProvider config={config} initialState={initialState}>
      <QueryClientProvider client={queryClient}>
        <BoardContextProvider>{children}</BoardContextProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

import { writeFileSync } from "fs";
import { join } from "path";

export type Network = "hardhat" | "sepolia";
export type DeployedContracts = {
  validator: string;
  battleshipFactory: string;
};

export function saveDeployedContracts(
  network: Network,
  addresses: DeployedContracts
) {
  const deployedContractsPath = join(
    __dirname,
    `../deployed-contracts/${network}.json`
  );
  writeFileSync(deployedContractsPath, JSON.stringify(addresses), {
    flag: "w",
  });
}

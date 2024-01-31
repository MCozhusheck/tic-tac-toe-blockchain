// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Battleship } from "../Battleship.sol";
import { MerkleTreeValidator } from "./MerkleTreeValidator.sol";

contract BattleshipFactory {
    address[] public deployedBattleships;
    MerkleTreeValidator public merkleTreeValidator;

    constructor(MerkleTreeValidator _merkleTreeValidator) {
        merkleTreeValidator = _merkleTreeValidator;
    }

    function createBattleship(bytes32 playerBoardRootHash) public {
        address newBattleship = address(new Battleship(merkleTreeValidator, playerBoardRootHash));
        deployedBattleships.push(newBattleship);
    }

    function getDeployedBattleships() public view returns (address[] memory) {
        return deployedBattleships;
    }
}
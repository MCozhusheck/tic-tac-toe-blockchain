// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Battleship } from "../Battleship.sol";
import { MerkleTreeValidator } from "./MerkleTreeValidator.sol";

contract BattleshipFactory {
    mapping(address => address[]) public deployedBattleships;
    MerkleTreeValidator public merkleTreeValidator;

    constructor(MerkleTreeValidator _merkleTreeValidator) {
        merkleTreeValidator = _merkleTreeValidator;
    }

    function createBattleship(bytes32 playerBoardRootHash) public payable returns (address) {
        address newBattleship = payable(address(new Battleship{value: msg.value}(merkleTreeValidator, playerBoardRootHash)));
        deployedBattleships[msg.sender].push(newBattleship);
        return newBattleship;
    }

    function getDeployedBattleships(address player) public view returns (address[] memory) {
        return deployedBattleships[player];
    }
}
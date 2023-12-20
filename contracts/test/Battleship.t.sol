// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Battleship} from "../src/Battleship.sol";
import {MerkleTreeValidator} from "../src/utils/MerkleTreeValidator.sol";

contract BattleshipTest is Test {
    Battleship public battleship;
    MerkleTreeValidator public validator;

    address player1 = address(this);
    address player2 = 0x0b216E10ef0771bc517616efb7FD375694AEC161;
    uint256 randomNumber1 = 123456789;
    uint256 randomNumber2 = 133769420;
    uint8[] shipPositions1;
    uint8[] shipPositions2;
    bytes32[] privateBoard1;
    bytes32[] privateBoard2;
    bytes32[] publicBoard1;
    bytes32[] publicBoard2;
    bytes32 rootHash1;
    bytes32 rootHash2;

    function setUp() public {
        validator = new MerkleTreeValidator();
        shipPositions1 = new uint8[](validator.BOARD_SIZE());
        shipPositions1[0] = 3;
        shipPositions1[1] = 5;
        shipPositions1[2] = 7;
        shipPositions1[3] = 11;
        privateBoard1 = validator.generateBoard(shipPositions1, randomNumber1);
        publicBoard1 = validator.hashBoard(privateBoard1);
        rootHash1 = validator.getTreeRootHash(publicBoard1);
        battleship = new Battleship{value: validator.STAKE_AMOUNT()}(
            validator,
            rootHash1
        );

        vm.startPrank(player2);
        deal(player2, validator.STAKE_AMOUNT() * 100);

        shipPositions2 = new uint8[](validator.BOARD_SIZE());
        shipPositions2[0] = 1;
        shipPositions2[1] = 2;
        shipPositions2[2] = 3;
        shipPositions2[3] = 15;
        privateBoard2 = validator.generateBoard(shipPositions2, randomNumber2);
        publicBoard2 = validator.hashBoard(privateBoard2);
        rootHash2 = validator.getTreeRootHash(publicBoard2);

        battleship.joinTheGame{value: validator.STAKE_AMOUNT()}(rootHash2);

        vm.stopPrank();
    }

    function testPlayer2JoinsGame() public {
        assertEq(player2, battleship.player2());
    }

    function testPlayer1Hits() public {
        uint8 attackPosition = shipPositions2[0];
        battleship.attack(attackPosition);
        vm.startPrank(player2);
        battleship.respondHit(publicBoard2[attackPosition]);
        vm.stopPrank();
    }

    function testPlayer1Miss() public {
        uint8 attackPosition = 4;
        battleship.attack(attackPosition);
        vm.startPrank(player2);
        bytes32[] memory verificationNodes = validator.getNodesToVerification(
            publicBoard2,
            attackPosition
        );
        battleship.respondMiss(verificationNodes, publicBoard2[attackPosition]);
    }
}

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

    function setUp() public {
        validator = new MerkleTreeValidator();
        uint8[] memory shipPositions = new uint8[](validator.BOARD_SIZE());
        shipPositions[0] = 3;
        shipPositions[1] = 5;
        shipPositions[2] = 7;
        shipPositions[3] = 11;
        bytes32[] memory board = validator.generateBoard(
            shipPositions,
            randomNumber1
        );
        bytes32 rootHash = validator.getTreeRootHash(board);
        battleship = new Battleship{value: validator.STAKE_AMOUNT()}(
            validator,
            rootHash
        );
    }

    function testPlayer2JoinsGame() public {
        vm.startPrank(player2);
        deal(player2, validator.STAKE_AMOUNT() * 100);

        uint8[] memory shipPositions = new uint8[](validator.BOARD_SIZE());
        shipPositions[0] = 1;
        shipPositions[1] = 2;
        shipPositions[2] = 3;
        shipPositions[3] = 15;
        bytes32[] memory board = validator.generateBoard(
            shipPositions,
            randomNumber2
        );
        bytes32 rootHash = validator.getTreeRootHash(board);

        battleship.joinTheGame{value: validator.STAKE_AMOUNT()}(rootHash);

        vm.stopPrank();
        assertEq(player2, battleship.player2());
    }
}

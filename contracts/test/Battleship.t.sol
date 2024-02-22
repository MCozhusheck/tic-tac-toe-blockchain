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

        uint256 playerScoredHits = battleship.getTotalHits(player1);
        uint256 expectedScoredHits = 1;
        assertEq(playerScoredHits, expectedScoredHits);
    }

    function testPlayer1Miss() public {
        uint8 attackPosition = 4;
        battleship.attack(attackPosition);
        vm.startPrank(player2);
        bytes32[] memory verificationNodes = validator.getNodesToVerification(publicBoard2, attackPosition);
        battleship.respondMiss(verificationNodes, publicBoard2[attackPosition]);
        vm.stopPrank();

        uint256 playerScoredHits = battleship.getTotalHits(player1);
        uint256 expectedScoredHits = 0;
        assertEq(playerScoredHits, expectedScoredHits);
    }

    function testPlayer1Wins() public {
        for (uint256 i = 0; i < shipPositions2.length; i++) {
            uint8 player1AttackPosition = shipPositions2[i];
            battleship.attack(player1AttackPosition);
            vm.startPrank(player2);
            battleship.respondHit(publicBoard2[player1AttackPosition]);
            if (battleship.state() == Battleship.GameState.WAITING_FOR_PROOFS) {
                vm.stopPrank();
                break;
            }
            uint8 player2AttackPosition = shipPositions1[i] + 1; // just attack where player 2 miss
            battleship.attack(player2AttackPosition);
            vm.stopPrank();

            bytes32[] memory verificationNodes = validator.getNodesToVerification(publicBoard1, player2AttackPosition);
            battleship.respondMiss(verificationNodes, publicBoard1[player2AttackPosition]);
        }

        bytes32[] memory missingNodes1 = new bytes32[](13); // player 2 shot 3 times
        uint256[] memory indices1 = new uint256[](13);
        uint256 missingNodes1Iter = 0;
        uint256 shipPositions1Iter = 0;
        for (uint256 i = 0; i < privateBoard1.length; i++) {
            if (i == shipPositions1[3] + 1) {
                missingNodes1[missingNodes1Iter] = privateBoard1[i];
                indices1[missingNodes1Iter] = i;
                missingNodes1Iter++;
            } else if (i == shipPositions1[shipPositions1Iter] + 1) {
                shipPositions1Iter++;
            } else {
                missingNodes1[missingNodes1Iter] = privateBoard1[i];
                indices1[missingNodes1Iter] = i;
                missingNodes1Iter++;
            }
        }
        battleship.verifyBoard(missingNodes1, indices1);

        vm.startPrank(player2);
        bytes32[] memory missingNodes2 = new bytes32[](12); // player 1 shot 4 times
        uint256[] memory indices2 = new uint256[](12);
        uint256 missingNodes2Iter = 0;
        uint256 shipPositions2Iter = 0;
        for (uint256 i = 0; i < privateBoard2.length; i++) {
            if (i == shipPositions2[shipPositions2Iter]) {
                shipPositions2Iter++;
            } else {
                missingNodes2[missingNodes2Iter] = privateBoard2[i];
                indices2[missingNodes2Iter] = i;
                missingNodes2Iter++;
            }
        }
        battleship.verifyBoard(missingNodes2, indices2);
        vm.stopPrank();

        uint256 player1BalanceBefore = player1.balance;
        battleship.claimPrize();
        uint256 player1BalanceAfter = player1.balance;
        uint256 expectedPrize = 2 * validator.STAKE_AMOUNT();
        assertEq(player1BalanceAfter - player1BalanceBefore, expectedPrize);
        assertEq(battleship.state() == Battleship.GameState.FINISHED, true);
    }

    fallback() external payable {}

    receive() external payable {}
}

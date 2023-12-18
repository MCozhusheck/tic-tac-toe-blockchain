// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract MerkleTreeValidator {
    uint8 public constant BOARD_SIZE = 16;
    uint8 public constant SHIPS_AMOUNT = 4;
    uint256 public constant STAKE_AMOUNT = 10 wei;

    function _efficientHash(
        bytes32 a,
        bytes32 b
    ) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function generateBoard(
        uint8[] memory shipsPositions,
        uint256 randomValue
    ) external pure returns (bytes32[] memory) {
        //TODO check if each ship posistion is different and if they are between 0-15 range;
        require(
            shipsPositions.length >= SHIPS_AMOUNT,
            "You need to place at least 4 ships"
        );

        bytes32[] memory board = new bytes32[](BOARD_SIZE);
        uint8 shipsIterator = 0;

        for (uint8 i = 0; i < BOARD_SIZE; i++) {
            uint256 salt = (
                ((uint256(keccak256(abi.encode(randomValue, i))) %
                    type(uint256).max) / 2)
            ) * 2;
            if (i == shipsPositions[shipsIterator]) {
                board[i] = bytes32(abi.encodePacked(salt));
                shipsIterator++;
            } else {
                board[i] = bytes32(abi.encodePacked(salt - 1));
            }
        }
        return board;
    }

    function verifyNode(
        bytes32[] memory nodes,
        bytes32 leaf,
        uint256 index,
        bytes32 root
    ) public pure returns (bool) {
        bytes32 hash = leaf;

        for (uint i = 0; i < nodes.length; i++) {
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, nodes[i]));
            } else {
                hash = keccak256(abi.encodePacked(nodes[i], hash));
            }

            index = index / 2;
        }

        return hash == root;
    }

    function getTreeRootHash(
        bytes32[] memory nodes
    ) public pure returns (bytes32) {
        bytes32[] memory hashes = nodes;
        uint256 currentLength = nodes.length;
        while (currentLength != 0) {
            for (uint256 i = 0; i < currentLength; i += 2) {
                hashes[i / 2] = _efficientHash(hashes[i], hashes[i + 1]);
            }
            currentLength = currentLength / 2;
        }

        return hashes[0];
    }

    function verifyTree(
        bytes32[] memory nodes,
        bytes32 root
    ) public pure returns (bool) {
        return getTreeRootHash(nodes) == root;
    }
}

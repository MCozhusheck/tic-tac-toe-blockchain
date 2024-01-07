// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

contract MerkleTreeValidator {
    uint8 public constant BOARD_SIZE = 16;
    uint8 public constant SHIPS_AMOUNT = 4;
    uint256 public constant STAKE_AMOUNT = 10 wei;

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function generateBoard(uint8[] memory shipsPositions, uint256 randomValue)
        external
        pure
        returns (bytes32[] memory)
    {
        //TODO check if each ship posistion is different and if they are between 0-15 range;
        require(shipsPositions.length >= SHIPS_AMOUNT, "You need to place at least 4 ships");

        bytes32[] memory board = new bytes32[](BOARD_SIZE);
        uint8 shipsIterator = 0;

        for (uint8 i = 0; i < BOARD_SIZE; i++) {
            uint256 salt = (((uint256(keccak256(abi.encode(randomValue, i))) % type(uint256).max) / 2)) * 2;
            if (i == shipsPositions[shipsIterator]) {
                board[i] = bytes32(abi.encodePacked(salt));
                shipsIterator++;
            } else {
                board[i] = bytes32(abi.encodePacked(salt - 1));
            }
        }
        return board;
    }

    function hashBoard(bytes32[] memory board) public pure returns (bytes32[] memory) {
        bytes32[] memory hashedBoard = new bytes32[](board.length);
        for (uint256 i = 0; i < board.length; i++) {
            hashedBoard[i] = keccak256(abi.encodePacked(board[i]));
        }

        return hashedBoard;
    }

    function getNodesToVerification(bytes32[] memory nodes, uint256 index) public pure returns (bytes32[] memory) {
        bytes32[] memory verificationNodes = new bytes32[](log2(nodes.length));
        uint256 verificationNodesIter = 0;

        bytes32[] memory hashes = nodes;
        uint256 currentLength = nodes.length / 2;

        while (currentLength != 0) {
            if (index % 2 == 0) {
                verificationNodes[verificationNodesIter] = hashes[index + 1];
            } else {
                verificationNodes[verificationNodesIter] = hashes[index - 1];
            }
            verificationNodesIter++;
            index = index / 2;

            for (uint256 i = 0; i < currentLength; i++) {
                hashes[i] = _efficientHash(hashes[2 * i], hashes[2 * i + 1]);
            }
            currentLength = currentLength / 2;
        }

        return verificationNodes;
    }

    function verifyNode(bytes32[] memory nodes, bytes32 leaf, uint256 index, bytes32 root) public pure returns (bool) {
        bytes32 hash = leaf;

        for (uint256 i = 0; i < nodes.length; i++) {
            if (index % 2 == 0) {
                hash = _efficientHash(hash, nodes[i]);
            } else {
                hash = _efficientHash(nodes[i], hash);
            }

            index = index / 2;
        }

        return hash == root;
    }

    function getTreeRootHash(bytes32[] memory nodes) public pure returns (bytes32) {
        bytes32[] memory hashes = nodes;
        uint256 currentLength = nodes.length / 2;

        while (currentLength != 0) {
            for (uint256 i = 0; i < currentLength; i++) {
                hashes[i] = _efficientHash(hashes[2 * i], hashes[2 * i + 1]);
            }
            currentLength = currentLength / 2;
        }

        return hashes[0];
    }

    function verifyTree(bytes32[] memory nodes, bytes32 root) public pure returns (bool) {
        return getTreeRootHash(nodes) == root;
    }

    function log2(uint256 x) public pure returns (uint256 y) {
        assembly {
            let arg := x
            x := sub(x, 1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m, 0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m, 0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m, 0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m, 0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m, 0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m, 0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m, 0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m, 0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m, sub(255, a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }
    }
}

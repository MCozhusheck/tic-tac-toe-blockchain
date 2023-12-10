// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MerkleTreeValidator {
    uint8 public constant BOARD_SIZE = 16;
    uint8 public constant SHIPS_AMOUNT = 4;

    function generateRandomNumber(uint256 max) external view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            ) % max;
    }

    function generateBoard(
        uint8[] memory shipsPositions
    ) external view returns (bytes32[] memory) {
        //TODO check if each ship posistion is different and if they are between 0-15 range;
        require(
            shipsPositions.length >= SHIPS_AMOUNT,
            "You need to place at least 4 ships"
        );

        bytes32[] memory board = new bytes32[](BOARD_SIZE);
        uint8 shipsIterator = 0;

        for (uint8 i = 0; i < BOARD_SIZE; i++) {
            uint256 salt = this.generateRandomNumber(type(uint256).max % 2);
            if (i == shipsIterator) {
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

    function verifyTree(
        bytes32[] memory nodes,
        bytes32 root
    ) public pure returns (bool) {
        if (nodes.length == 1) {
            return nodes[0] == root;
        }
        bytes32[] memory hashes = new bytes32[](nodes.length / 2);

        for (uint i = 0; i < nodes.length; i + 2) {
            hashes[i / 2] = keccak256(abi.encodePacked(nodes[i], nodes[i + 1]));
        }

        return verifyTree(hashes, root);
    }
}

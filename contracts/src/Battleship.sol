// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Battleship {
    address payable public player1;
    address payable public player2;

    mapping(address => bytes32) public rootHash;
    mapping(address => bytes32[]) public boards;
    mapping(address => uint8) public scoredHits;
    mapping(address => bool) public hasVerifiedBoard;

    uint8 public constant BOARD_SIZE = 16;
    uint256 public constant STAKE_AMOUNT = 10 wei;
    uint8 public constant SHIPS_AMOUNT = 4;
    bytes32 public constant REPORTED_HIT = "1";

    uint8 public lastAttack;
    address public currentUser;

    enum GameState {
        WAITING_FOR_USER_2,
        PLAYER_ATTACKS,
        PLAYER_RESPONDS,
        WAITING_FOR_PROOFS,
        WAITING_FOR_PRIZE_CLAIM,
        FINISHED
    }

    GameState public state;

    constructor(bytes32 _player1Hash) payable {
        require(msg.value == STAKE_AMOUNT, "Invalid staked amount");
        player1 = payable(msg.sender);
        rootHash[player1] = _player1Hash;
        boards[player1] = new bytes32[](BOARD_SIZE);
        scoredHits[player1] = 0;
        state = GameState.WAITING_FOR_USER_2;
    }

    modifier onlyWhenWaitingForPlayer2() {
        require(state == GameState.WAITING_FOR_USER_2);
        _;
    }

    modifier onlyCurrentUser() {
        require(msg.sender == currentUser);
        _;
    }

    modifier onlyUserThatCanAttack() {
        require(state == GameState.PLAYER_ATTACKS && msg.sender == currentUser);
        _;
    }

    modifier onlyUserThatCanRespond() {
        require(
            state == GameState.PLAYER_RESPONDS && msg.sender == currentUser
        );
        _;
    }

    modifier onlyUserThatNeedsToProve() {
        require(
            (msg.sender == player1 && !hasVerifiedBoard[player1]) ||
                (msg.sender == player2 && !hasVerifiedBoard[player2])
        );
        _;
    }

    modifier onlyWinner() {
        require(
            msg.sender == checkForWinner() &&
                state == GameState.WAITING_FOR_PRIZE_CLAIM
        );
        _;
    }

    function getOtherUser() internal view returns (address) {
        if (currentUser == player1) {
            return player2;
        } else {
            return player1;
        }
    }

    function switchCurrentUser() internal {
        currentUser = getOtherUser();
    }

    function checkForWinner() internal view returns (address winner) {
        if (scoredHits[player1] >= SHIPS_AMOUNT) {
            return player1;
        } else if (scoredHits[player2] >= SHIPS_AMOUNT) {
            return player2;
        }

        return address(0);
    }

    function joinTheGame(
        bytes32 _player2hash
    ) public payable onlyWhenWaitingForPlayer2 {
        require(msg.value == STAKE_AMOUNT, "Invalid staked amount");

        player2 = payable(msg.sender);
        rootHash[player2] = _player2hash;
        boards[player2] = new bytes32[](BOARD_SIZE);
        scoredHits[player2] = 0;
        state = GameState.PLAYER_ATTACKS;
        currentUser = player1;
    }

    function attack(uint8 field) public onlyUserThatCanAttack {
        require(field < BOARD_SIZE, "An attack must be within board size");

        lastAttack = field;
        state = GameState.PLAYER_RESPONDS;
        switchCurrentUser();
    }

    function respondHit(bytes32 node) public onlyUserThatCanRespond {
        scoredHits[getOtherUser()] += 1;
        boards[currentUser][lastAttack] = node;

        if (checkForWinner() != address(0)) {
            state = GameState.WAITING_FOR_PROOFS;
        } else {
            state = GameState.PLAYER_ATTACKS;
        }
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

    function respondMiss(
        bytes32[] memory nodes,
        bytes32 leaf
    ) public onlyUserThatCanRespond {
        bool userVerifiedRespond = verifyNode(
            nodes,
            leaf,
            lastAttack,
            rootHash[currentUser]
        );
        require(userVerifiedRespond, "Invalid nodes");

        boards[currentUser][lastAttack] = nodes[0];
        state = GameState.PLAYER_ATTACKS;
    }

    function verifyBoard(
        bytes32[] memory nodes,
        uint256[] memory indices
    ) public onlyUserThatNeedsToProve {
        require(
            nodes.length == indices.length,
            "Both arrays must be same length"
        );

        bytes32[] memory boardCopy = boards[msg.sender];

        for (uint256 i = 0; i < nodes.length; i++) {
            uint256 nodeIndex = indices[i];
            boardCopy[nodeIndex] = nodes[i];
        }

        bool playerHasVerifiedBoard = verifyTree(
            boardCopy,
            rootHash[msg.sender]
        );
        require(playerHasVerifiedBoard, "Board has not been verified");

        boards[msg.sender] = boardCopy;
        hasVerifiedBoard[msg.sender] = true;

        if (hasVerifiedBoard[currentUser] && hasVerifiedBoard[getOtherUser()]) {
            state = GameState.WAITING_FOR_PRIZE_CLAIM;
        }
    }

    function claimPrize() public onlyWinner {
        payable(checkForWinner()).transfer(2 * STAKE_AMOUNT);
        state = GameState.FINISHED;
    }
}

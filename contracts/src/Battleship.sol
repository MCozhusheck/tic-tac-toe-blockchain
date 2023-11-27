// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Battleship {
    address payable public player1;
    address payable public player2;

    mapping(address => string) public proofs;
    mapping(address => bool[]) public boards;
    mapping(address => uint8) public playerHits;
    mapping(address => uint256[]) public fieldSalts;

    uint8 public constant BOARD_SIZE = 16;
    uint256 public constant STAKE_AMOUNT = 10 wei;
    uint8 public constant SHIPS_AMOUNT = 4;

    uint8 public lastAttack;
    address public currentUser;

    enum GameState {
        WAITING_FOR_USER_2,
        PLAYER_ATTACKS,
        PLAYER_RESPONDS,
        WAITING_FOR_PROOFS,
        FINISHED
    }

    GameState public state;

    constructor(string memory _player1Hash) payable {
        require(msg.value == STAKE_AMOUNT, "Invalid staked amount");
        player1 = payable(msg.sender);
        proofs[player1] = _player1Hash;
        boards[player1] = new bool[](BOARD_SIZE);
        playerHits[player1] = 0;
        fieldSalts[player1] = new uint256[](BOARD_SIZE);
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
        if (playerHits[player1] >= SHIPS_AMOUNT) {
            return player1;
        } else if (playerHits[player2] >= SHIPS_AMOUNT) {
            return player2;
        }
    }

    function joinTheGame(
        string memory _player2hash
    ) public payable onlyWhenWaitingForPlayer2 {
        require(msg.value == STAKE_AMOUNT, "Invalid staked amount");

        player2 = payable(msg.sender);
        proofs[player2] = _player2hash;
        boards[player2] = new bool[](BOARD_SIZE);
        playerHits[player2] = 0;
        fieldSalts[player2] = new uint256[](BOARD_SIZE);
        state = GameState.PLAYER_ATTACKS;
        currentUser = player1;
    }

    function attack(uint8 field) public onlyUserThatCanAttack {
        require(field < BOARD_SIZE, "An attack must be within board size");

        boards[currentUser][field] = true;
        lastAttack = field;

        state = GameState.PLAYER_RESPONDS;
        switchCurrentUser();
    }

    function respondHit() public onlyUserThatCanRespond {
        playerHits[getOtherUser()] += 1;

        if (checkForWinner() != address(0)) {
            state = GameState.WAITING_FOR_PROOFS;
        } else {
            state = GameState.PLAYER_ATTACKS;
        }
    }

    function respondMiss(uint256 proof) public onlyUserThatCanRespond {
        fieldSalts[currentUser][lastAttack] = proof;
        state = GameState.PLAYER_ATTACKS;
    }
}

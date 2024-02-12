//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address payable[] public players;

    event WinnerSelected( address indexed winner, uint amountWon);

    modifier onlyManager {
        require( msg.sender == manager, " Only manager can call this function");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function enter() external payable {
        require( msg.value > 0, "Please a positive and not null number");
    }

    function getPlayers() external view returns(address payable[] memory) {
        return players;
    }

    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length)));
    }

    function pickWinner() external onlyManager {
        require(players.length > 0, "No players participated in the lottery");

        uint index = random() % players.length;
        address payable winner = players[index];
        emit WinnerSelected(winner, address(this).balance);
        winner.transfer(address(this).balance);
        players = new address payable[](0);
    }
}
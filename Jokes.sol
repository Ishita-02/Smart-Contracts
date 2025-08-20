// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Jokes {

    uint256 private constant CLASSIC_REWARD = 0.001 ether;
    uint256 private constant FUNNY_REWARD = 0.005 ether;
    uint256 private constant GROANER_REWARD = 0.01 ether;

    mapping(uint8 => uint256) private rewardAmounts;

    constructor() {
        rewardAmounts[1] = CLASSIC_REWARD;
        rewardAmounts[2] = FUNNY_REWARD;
        rewardAmounts[3] = GROANER_REWARD;
    }

    event JokeAdded(uint256, address);
    event JokeRewarded(uint256, uint8, uint256);
    event JokeDeleted(uint256);
    event BalanceWithdrawn(address, uint256);

    struct Joke {
        string setup;
        string punchline;
        address creator;
        bool deleted;
    }

    mapping(uint256 => Joke) jokeById;
    mapping (address => uint256) creatorBalances;

    uint256 jokeCounter = 0;

    function addJoke(string memory _setup, string memory _punchLine) public {

        jokeCounter++;

        jokeById[jokeCounter] = Joke({
            setup: _setup,
            punchline: _punchLine,
            creator: msg.sender,
            deleted: false
        });

        emit JokeAdded(jokeCounter, msg.sender);
    }

    function getJokes() public view returns(Joke[] memory) {
        uint256 activeCount = 0;

        for (uint256 i = 1; i <= jokeCounter; i++) {
            if (!jokeById[i].deleted) {
                activeCount++;
            }
        }

        Joke[] memory jokes = new Joke[](activeCount);
        uint256 counter = 0;

        for (uint256 i = 1; i <= jokeCounter; i++) {
            if (!jokeById[i].deleted) {
                jokes[counter] = jokeById[i];
                counter++;
            }
        }

        return jokes;
    }


    function rewardJoke(uint256 jokeId, uint8 _rewardType) public payable {
        require(jokeId <= jokeCounter && jokeId >0);
        require(jokeById[jokeId].deleted == false);
        require(_rewardType >0 && _rewardType < 4);

        uint256 rewardAmount = rewardAmounts[_rewardType];
        require(msg.value == rewardAmount, "Incorrect reward amount");

        address creator = jokeById[jokeId].creator;
        creatorBalances[creator] += msg.value;

        emit JokeRewarded(jokeId, _rewardType, msg.value);
    }

    function deleteJoke(uint256 jokeId) public {
        require(jokeById[jokeId].creator == msg.sender);

        jokeById[jokeId] = Joke("", "", address(0), true);

        emit JokeDeleted(jokeId);
    }

    function withdrawBalance() public {
        uint256 balance = creatorBalances[msg.sender];

        creatorBalances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success);        

        emit BalanceWithdrawn(msg.sender, balance);
    }
}
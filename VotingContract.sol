//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract VotingContract {
    address public admin;
    
    struct Ballot {
        uint id;
        mapping(uint => uint) votes;
        bool isOpen;
        bool isFinalized; 
    }

    mapping(uint => Ballot) public ballots;
    mapping(address => bool) registeredVoters;
    mapping(address => mapping(uint => bool)) public hasVoted;

    event BallotCreated(uint indexed id);
    event voteCast(uint indexed ballotId, uint indexed optionId, address indexed voter);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerVoter(address _voter) external onlyAdmin {
        registeredVoters[_voter] = true;
    }

    function createBallot(uint _id) external onlyAdmin {
        require(!ballots[_id].isOpen && !ballots[_id].isFinalized, "Ballot with the same Id already exists");

        ballots[_id].id = _id;
        ballots[_id].isOpen = true;

        emit BallotCreated(_id);
    }

    function castVote(uint _ballotId, uint _optionId) external {
        require( registeredVoters[msg.sender], "Voter is not registered.");
        require( ballots[_ballotId].isOpen, "Voting for this ballot is closed now." );
        require( !hasVoted[msg.sender][_ballotId], "Sender has already voted for this." );

        ballots[_ballotId].votes[_optionId]++;
        hasVoted[msg.sender][_ballotId] = true;

        emit voteCast(_ballotId, _optionId, msg.sender);
    }

}
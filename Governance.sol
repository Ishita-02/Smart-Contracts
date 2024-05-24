// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Voting {

    address[] public owners;

    mapping(address => bool) public isOwner;

    constructor(address[] memory _owners) {
        require(_owners.length > 0, "Owners required");

        address deployer = msg.sender;
        owners.push(deployer);
        isOwner[deployer] = true;

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner address");
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
    }

    Proposal[] public proposals;

    mapping(address => mapping(uint => bool)) userVoted;
    mapping(address => mapping(uint => bool)) trackUserVote;
    mapping(uint => bool) isExecuted;

    event ProposalCreated (uint proposalId);
    event VoteCast(uint proposalId, address voterAddress);

    function newProposal(address _target, bytes calldata _data) external onlyOwner {
        Proposal memory addProposal = Proposal({
            target: _target, 
            data: _data, 
            yesCount: 0, 
            noCount: 0
        });
        proposals.push(addProposal);
        emit ProposalCreated(proposals.length-1);
    }

    function castVote(uint _proposalId, bool _supports) external onlyOwner {
        require(_proposalId <= proposals.length && _proposalId >= 0);
        require(isExecuted[_proposalId] == false);
        if(userVoted[msg.sender][_proposalId] == false) {
            if(_supports == true) {
            proposals[_proposalId].yesCount++;
            userVoted[msg.sender][_proposalId] = true;
            trackUserVote[msg.sender][_proposalId] = true;
            } else if(_supports == false) {
                proposals[_proposalId].noCount++;
                userVoted[msg.sender][_proposalId] = true;
                trackUserVote[msg.sender][_proposalId] = false;
            }
        } else {
            if(trackUserVote[msg.sender][_proposalId] == true && _supports == false) {
                trackUserVote[msg.sender][_proposalId] = false;
                proposals[_proposalId].yesCount--;
                proposals[_proposalId].noCount++;
            } else if(trackUserVote[msg.sender][_proposalId] == false && _supports == true) {
                trackUserVote[msg.sender][_proposalId] = true;
                proposals[_proposalId].yesCount++;
                proposals[_proposalId].noCount--;
            }
        }
        if(proposals[_proposalId].yesCount >=10) {
            address targetAddress = proposals[_proposalId].target;
            bytes memory data = proposals[_proposalId].data;
            (bool success, ) = targetAddress.call{value: address(this).balance}(data);
            require(success, "Call failed");
            isExecuted[_proposalId] = true;
        }
        emit VoteCast(_proposalId, msg.sender);
    }
    
}

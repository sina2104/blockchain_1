// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint public candidatesCount;
    uint public totalVotes;

    constructor() {
        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
    }

    function addCandidate(string memory _name) private {
        candidates[candidatesCount] = Candidate(_name, 0);
        candidatesCount++;
    }

    function vote(uint _candidateId) public {
        require(!voters[msg.sender], "You've already voted.");
        require(_candidateId < candidatesCount, "Invalid Candidate ID.");

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        totalVotes++;
    }

    function getWinner() public view returns (string memory winnerName) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerName = candidates[i].name;
            }
        }
    }
}
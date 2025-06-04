// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./MyToken.sol"; // если в том же проекте

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint public candidatesCount;
    uint public totalVotes;
    MyToken public token;

    constructor(MyToken _token) {
        token = _token;
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
        require(token.balanceOf(msg.sender) >= 1, "Not enough tokens.");
        require(token.allowance(msg.sender, address(this)) >= 1, "Allowance too low.");

        token.transferFrom(msg.sender, address(this), 1);
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        totalVotes++;
    }
    
    function getCandidateVotes(uint _candidateId) public view returns (uint voteCount) {
        require(_candidateId < candidatesCount, "Invalid Candidate ID.");
        return candidates[_candidateId].voteCount;
    }

    function getWinner() public view returns (string memory winnerName) {
    uint winningVoteCount = 0;
    bool isTie = false;

    for (uint i = 0; i < candidatesCount; i++) {
        if (candidates[i].voteCount > winningVoteCount) {
            winningVoteCount = candidates[i].voteCount;
            winnerName = candidates[i].name;
            isTie = false;
        } else if (candidates[i].voteCount == winningVoteCount && winningVoteCount != 0) {
            isTie = true;
        }
    }
    }
}
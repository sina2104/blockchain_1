// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ImprovedVoting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint public candidatesCount;
    uint public totalVotes;
    bool public votingClosed;

    event VoteCast(address indexed voter, uint candidateId);
    event VotingEnded(string result);

    constructor(string[] memory _candidateNames) {
        require(_candidateNames.length >= 2, "At least 2 candidates required");
        for (uint i = 0; i < _candidateNames.length; i++) {
            addCandidate(_candidateNames[i]);
        }
    }

    function addCandidate(string memory _name) private {
        candidates[candidatesCount] = Candidate(_name, 0);
        candidatesCount++;
    }

    function vote(uint _candidateId) public {
        require(!votingClosed, "Voting is closed");
        require(!voters[msg.sender], "You've already voted");
        require(_candidateId < candidatesCount, "Invalid candidate ID");

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        totalVotes++;

        emit VoteCast(msg.sender, _candidateId);
    }

    function endVoting() public {
        require(!votingClosed, "Voting already closed");
        votingClosed = true;
        
        (string memory result, ) = getWinner();
        emit VotingEnded(result);
    }

    function getWinner() public view returns (string memory result, uint[] memory winners) {
        require(votingClosed, "Voting is not closed yet");
        
        uint maxVotes = 0;
        uint winnerCount = 0;
        
        // Первый проход: находим максимальное количество голосов
        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerCount = 1;
            } else if (candidates[i].voteCount == maxVotes) {
                winnerCount++;
            }
        }
        
        // Второй проход: собираем всех победителей
        winners = new uint[](winnerCount);
        uint index = 0;
        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount == maxVotes) {
                winners[index] = i;
                index++;
            }
        }
        
        // Формируем текстовый результат
        if (winnerCount == 1) {
            result = candidates[winners[0]].name;
        } else {
            result = "Tie between: ";
            for (uint i = 0; i < winners.length; i++) {
                result = string(abi.encodePacked(result, candidates[winners[i]].name));
                if (i < winners.length - 1) {
                    result = string(abi.encodePacked(result, ", "));
                }
            }
        }
    }
}

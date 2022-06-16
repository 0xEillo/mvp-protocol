// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./WKND.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import {Errors} from "../contracts/libs/Errors.sol";

contract Candidates is Ownable {
    WKND _wknd;

    uint256 public _counter = 0;

    struct Voter {
        bool hasVoted;
        uint256 votesRemaigning;
    }

    // candidate struct
    struct Candidate {
        uint256 id;
        string name;
        uint256 age;
        string cult;
        uint256 votes;
    }

    mapping(address => Voter) _voters;
    mapping(uint256 => Candidate) _candidatesMapping;

    // Candidates storage arrays
    Candidate[] public _candidates;
    Candidate[3] public _winningCandidates;

    event HasVoted(address voter, uint256 id, uint256 weight);
    event NewChallenger(Candidate candidate);

    constructor(WKND wknd) {
        _wknd = wknd;
    }

    function addCandidates(Candidate[] memory candidates) external onlyOwner {
        for (uint256 i; i < candidates.length; i++) {
            Candidate memory tempCandidate;
            tempCandidate.id = _counter += 1;
            tempCandidate.name = candidates[i].name;
            tempCandidate.age = candidates[i].age;
            tempCandidate.cult = candidates[i].cult;
            _candidates.push(tempCandidate);
        }
    }

    function vote(uint256 weight, uint256 id) external {
        address voter = msg.sender;
        if (_candidates.length == 0) {
            revert Errors.NoCandidatesSignedUp();
        }
        if (!(_wknd.balanceOf(voter) > 0)) {
            revert Errors.InsufficientTokenBalance(_wknd.balanceOf(voter), 1);
        }
        if (!(_wknd.balanceOf(voter) >= weight)) {
            revert Errors.InsufficientTokenBalance(
                _wknd.balanceOf(voter),
                weight
            );
        }
        if (!(id < _candidates.length)) {
            revert Errors.InvalidId(id);
        }

        if (_voters[voter].hasVoted == false) {
            _voters[voter].votesRemaigning = _wknd.balanceOf(voter) - weight;
            _voters[voter].hasVoted = true;
        } else {
            if (!(_voters[voter].votesRemaigning >= weight)) {
                revert Errors.InsufficientVotesRemaigning(
                    _voters[voter].votesRemaigning,
                    weight
                );
            }
            _voters[voter].votesRemaigning -= weight;
            _voters[voter].hasVoted = true;
        }
        for (uint256 i; i < _candidates.length; i++) {
            if (_candidates[i].id == id) {
                _candidates[i].votes += weight;
                if (_candidates[i].votes > _winningCandidates[2].votes) {
                    _sortWinners(_candidates[i]);
                    emit NewChallenger(_candidates[i]);
                }
            }
        }
        emit HasVoted(voter, id, weight);
    }

    function winningCandidates() external view returns (Candidate[3] memory) {
        return _winningCandidates;
    }

    function _sortWinners(Candidate memory candidate) internal {
        for (uint256 i; i < 3; i++) {
            if (candidate.votes > _winningCandidates[i].votes) {
                _winningCandidates[i] = candidate;
                break;
            }
        }
    }
}

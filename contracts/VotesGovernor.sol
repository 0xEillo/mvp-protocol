// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./WKND.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "../contracts/libs/Errors.sol";

/**
 * @author eillo.eth
 * @notice VotesGovernor is a contract built to handle the upcoming Wakandan
 *         officials elections. Wakandan citizens can call this contract to
 *         to vote on-chain for their chosen offical. The contract can also
 *         be used as a leaderboard to see the winning candidates.
 */
contract VotesGovernor is Ownable {
    // WKND token needed to vote in the election.
    WKND wkndToken;

    // counter used to set the id's of the candidates.
    uint256 public _counter = 0;

    // Struct to represent a candidate in the election.
    struct Candidate {
        uint256 id;
        string name;
        uint256 age;
        string cult;
        uint256 votes;
    }

    // mapping from a voter's address to a boolean.
    // Given the spec an address can only vote once
    // with more or less weight. Therefor this
    // mapping keeps track of the remainging votes: 0 || 1
    mapping(address => bool) public _hasVoted;

    // Storage array of all candidates in the election.
    Candidate[] public _candidates;
    Candidate[3] public _winningCandidates;

    /**
     * @notice Event emitted every time a Voter votes for a candidate.
     *
     * @param voter  Address of the voter.
     * @param id     Id of the candidate.
     * @param weight Number of votes being given.
     */
    event HasVoted(address voter, uint256 id, uint256 weight);

    /**
     * @notice Event emmitted  whenever a new candidate enters the top 3
     *
     * @param candidate Candidate struct entering the top 3.
     */
    event NewChallanger(Candidate candidate);

    /**
     * @param wknd WKND token required for voters to vote.
     */
    constructor(WKND wknd) {
        wkndToken = wknd;
    }

    /**
     * @notice External function called to add candidates to the election.
     *         **NOTE: This function can only be called by the owner.
     *
     * @param candidates Array of candidates to be added to the election.
     */
    function addCandidates(Candidate[] memory candidates) external onlyOwner {
        for (uint256 i; i < candidates.length; i++) {
            _counter += 1;
            Candidate memory tempCandidate;
            tempCandidate.id = _counter;
            tempCandidate.name = candidates[i].name;
            tempCandidate.age = candidates[i].age;
            tempCandidate.cult = candidates[i].cult;
            tempCandidate.votes = 0;
            _candidates.push(tempCandidate);
        }
    }

    /**
     * @notice External function called by voters to cast a vote.
     *
     * @param id     The id of a candidate.
     * @param weight The number of votes being attributed to a candidate.
     */
    function vote(uint256 id, uint256 weight) external {
        address voter = msg.sender;
        if (_candidates.length == 0) revert Errors.NoCandidatesSignedUp();

        if (
            (wkndToken.balanceOf(voter) == 0) ||
            (weight > wkndToken.balanceOf(voter))
        )
            revert Errors.InsufficientTokenBalance(
                wkndToken.balanceOf(voter),
                weight
            );

        if (id == 0 || !(id <= _candidates.length)) revert Errors.InvalidId(id);

        if (_hasVoted[voter] == true) revert Errors.HasVoted();

        for (uint256 i; i < _candidates.length; i++) {
            if (_candidates[i].id == id) {
                _candidates[i].votes += weight;
                _challenger(_candidates[i]);
                _sortCandidates();
            }
        }

        _hasVoted[voter] = true;
        emit HasVoted(voter, id, weight);
    }

    /**
     * @notice External function called to get the top 3 candidates.
     */
    function winningCandidates() external view returns (Candidate[3] memory) {
        return _winningCandidates;
    }

    /**
     * @notice Function returns true if an address has votes, otherwise false.
     *
     * @param voter Address of the voter.
     */
    function hasVoted(address voter) external view returns (bool) {
        return _hasVoted[voter];
    }

    /**
     * @notice Function sorts the storage array of candidates using the
     *         bubble sort algorithm.
     */
    function _sortCandidates() internal {
        for (uint256 i; i < _candidates.length - 1; i++) {
            for (uint256 j; j < _candidates.length - 1; j++) {
                if (_candidates[j].votes < _candidates[j + 1].votes) {
                    Candidate memory currentCandidate = _candidates[j];
                    _candidates[j] = _candidates[j + 1];
                    _candidates[j + 1] = currentCandidate;
                }
            }
        }
        _winningCandidates[0] = _candidates[0];
        _winningCandidates[1] = _candidates[1];
        _winningCandidates[2] = _candidates[2];
    }

    /**
     * @notice Function checks if there is a new challenger in the
     *         top 3.
     *
     * @param challenger Candidate reviewed to be in the top3.
     */
    function _challenger(Candidate memory challenger) internal {
        // loop through winning candidates and check if the challenger has more votes.
        for (uint256 i; i < 3; i++) {
            if (challenger.votes > _winningCandidates[i].votes) {
                // only emit event if the challenger is not already in the top 3 or
                // if the votes count is equal to 0.
                if (
                    (challenger.id != _winningCandidates[0].id &&
                        challenger.id != _winningCandidates[1].id &&
                        challenger.id != _winningCandidates[2].id) ||
                    (_winningCandidates[i].votes == 0)
                ) {
                    emit NewChallanger(challenger);
                    break;
                }
            }
        }
    }
}

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

    // Struct to represend a voter. A voter may vote more than once.
    struct Voter {
        // Defaults to false. Is set to true once a voter has voted once.
        bool hasVoted;
        // The number of votes remaigning for a voter given his token balance.
        uint256 votesRemaigning;
    }

    // Struct to represent a candidate in the election.
    struct Candidate {
        uint256 id;
        string name;
        uint256 age;
        string cult;
        uint256 votes;
    }

    // mapping from a voter's address to a Voter struct.
    mapping(address => Voter) _voters;

    // mapping from an id to a Candidate struct.
    mapping(uint256 => Candidate) _candidatesMapping;

    // Storage array of all candidates in the election.
    Candidate[] public _candidates;

    // Storage array of the top 3 candidates.
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
    event NewChallenger(Candidate candidate);

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
            Candidate memory tempCandidate;
            tempCandidate.id = _counter += 1;
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
     * @param weight The number of votes being attributed to a candidate.
     * @param id     The id of a candidate.
     */
    function vote(uint256 weight, uint256 id) external {
        address voter = msg.sender;
        if (_candidates.length == 0) {
            revert Errors.NoCandidatesSignedUp();
        }
        if (!(wkndToken.balanceOf(voter) > 0)) {
            revert Errors.InsufficientTokenBalance(0, 1);
        }
        if (!(wkndToken.balanceOf(voter) >= weight)) {
            revert Errors.InsufficientTokenBalance(
                wkndToken.balanceOf(voter),
                weight
            );
        }
        if (!(id <= _candidates.length)) {
            revert Errors.InvalidId(id);
        }

        // check if the voter has not yet voted
        if (_voters[voter].hasVoted == false) {
            // set the remaigning votes to the token balance minus the weight.
            _voters[voter].votesRemaigning =
                wkndToken.balanceOf(voter) -
                weight;
            _voters[voter].hasVoted = true;
        } else {
            // check if the voter is trying to vote more times than votes remaigning.
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

    /**
     * @notice External function called to get the top 3 candidates.
     */
    function winningCandidates() external view returns (Candidate[3] memory) {
        return _winningCandidates;
    }

    /**
     * @notice Internal function called to sort the top 3 candidates. This
     *         function is called on every vote.
     */
    function _sortWinners(Candidate memory candidate) internal {
        for (uint256 i; i < 3; i++) {
            if (candidate.votes > _winningCandidates[i].votes) {
                _winningCandidates[i] = candidate;
                break;
            }
        }
    }
}

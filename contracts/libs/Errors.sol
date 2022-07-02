// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library Errors {
    error NoCandidatesSignedUp();
    error InsufficientTokenBalance(
        uint256 tokenBalance,
        uint256 expectedBalance
    );
    error InvalidId(uint256 id);
    error InsufficientVotesRemaigning(
        uint256 votesRemaigning,
        uint256 expectedVotesRemaigning
    );
    error AllTokensClaimed();
    error HasClaimed();
    error HasVoted();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Reputation.sol";
import "./ProposalModifier.sol";

contract Unfakenews {
    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        uint256 nftId;
    }

    mapping(uint256 => Proposal) private _proposals;
    uint256 private _proposalCount;

    Reputation private immutable reputationToken;
    ProposalModifier private immutable proposalModifier;

    event VoteRequested(uint256 proposalId, uint256 nftId);

    constructor(
        Reputation _token,
        ProposalModifier _modifier
    ) {
        reputationToken = _token;
        proposalModifier = _modifier;
    }

    function requestVoteForNFT(uint256 nftId) external {
        uint256 totalReputation = reputationToken.totalSupply();
        uint256 callerReputation = reputationToken.balanceOf(msg.sender);

        if (totalReputation > 1e6) {
            require(callerReputation >= 1e3, "Insufficient reputation");
        }

        uint256 proposalId = proposalModifier.createProposal();
        _proposals[proposalId].nftId = nftId;

        emit VoteRequested(proposalId, nftId);
    }

    function voteFor(uint256 proposalId, uint256 reputationStake) external {
        _countVote(proposalId, msg.sender, 1, reputationStake, bytes(""));
        proposalModifier.castVote(proposalId, reputationStake, true, msg.sender);
    }

    function voteAgainst(uint256 proposalId, uint256 reputationStake) external {
        _countVote(proposalId, msg.sender, 0, reputationStake, bytes(""));
        proposalModifier.castVote(proposalId, reputationStake, false, msg.sender);
    }

    function addressExists(address[] memory addresses, address target) internal pure returns (bool) {
    for (uint256 i = 0; i < addresses.length; i++) {
        if (addresses[i] == target) {
            return true; // Address found in the list
        }
    }
    return false; // Address not found in the list
    }

    function hasVoted(uint256 proposalId, address voter) internal view returns (bool) {
    Proposal storage proposal = _proposals[proposalId];
    (forVoters, againstVoters) = proposalModifier.getVoters(proposalID);
    return addressExists(forVoters, voter) || addressExists(againstVoters, voter);
    }



    function _countVote(
        uint256 proposalId,
        address voter,
        uint8 support,
        uint256 reputationStake,
        bytes memory reason
    ) internal {
        require(proposalId <= _proposalCount, "Invalid proposal");
        require(!hasVoted(proposalId, voter), "Already voted");
        require(reputationToken.balanceOf(voter) >= reputationStake, "Insufficient reputation");

        // Update the vote count
        if (support == 1) {
            _proposals[proposalId].forVotes += reputationStake;
        } else {
            _proposals[proposalId].againstVotes += reputationStake;
        }
    }

    function _execute(uint256 proposalId) internal {
        Proposal storage proposal = _proposals[proposalId];
        proposal.executed = true;

        uint256 forVotes = proposal.forVotes;
        uint256 againstVotes = proposal.againstVotes;

        if (forVotes > againstVotes) {
            proposalModifier.executeProposal(proposalId);
        }

    }

    // Implement the required functions from the imported governance contracts

    function votingPeriod() public pure returns (uint256) {
        // Set the minimum voting period to 7 days
        return 7 days;
    }

    function quorumNumerator() public pure returns (uint256) {
        // The quorum numerator should be 30% of the total reputation supply
        return 30;
    }

    function quorum(uint256 blockNumber) public view returns (uint256) {
        // Calculate the quorum based on the total reputation supply
        uint256 totalReputation = reputationToken.totalSupply();
        return (totalReputation * quorumNumerator()) / 100;
    }

    function proposalThreshold() public pure returns (uint256) {
        // The proposal threshold should be 1% of the total reputation supply
        return 1;
    }
}

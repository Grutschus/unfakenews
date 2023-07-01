// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "./Reputation.sol";
import "./ProposalModifier.sol";

contract Unfakenews is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    Reputation private immutable reputationToken;
    ProposalModifier private immutable proposalModifier;

    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        uint256 nftId;
    }

    mapping(uint256 => Proposal) private _proposals;
    uint256 private _proposalCount;

    event VoteRequested(uint256 proposalId, uint256 nftId);

    constructor(
        Reputation _token,
        ProposalModifier _modifier
    )
        Governor("Unfakenews")
        GovernorSettings(7200 /* 1 day */, 50400 /* 1 week */, 10)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(30)
    {
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
        emit VoteCast(msg.sender, proposalId, 1, reputationStake, "Raisin blanc");
    }

    function voteAgainst(uint256 proposalId, uint256 reputationStake) external {
        _countVote(proposalId, msg.sender, 0, reputationStake, bytes(""));
        proposalModifier.castVote(proposalId, reputationStake, false, msg.sender);
        emit VoteCast(msg.sender, proposalId, 0, reputationStake, "Raisin blanc");
    }

    function _execute(uint256 proposalId) internal{
        Proposal storage proposal = _proposals[proposalId];
        proposal.executed = true;

        uint256 forVotes = proposal.forVotes;
        uint256 againstVotes = proposal.againstVotes;

        if (forVotes > againstVotes) {
            proposalModifier.executeProposal(proposalId);
        }

        emit ProposalExecuted(proposalId);
    }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        pure
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        // Set the minimum voting period to 7 days
        return 7 days;
    }

    function quorumNumerator()
        public
        pure
        override(GovernorVotesQuorumFraction)
        returns (uint256)
    {
        // The quorum numerator should be 30% of the total reputation supply
        return 30;
    }function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        // quorumNumerator() returns the percentage of the total supply that is required for quorum
        return super.quorum(blockNumber);
    }

    

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Reputation.sol";

contract Unfakenews is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{

    Reputation private immutable reputationToken;

    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => uint256) reputationStaked;
        address[] votersFor;
        address[] votersAgainst;
    }

    mapping(uint256 => Proposal) private _proposals;
    uint256 private _proposalCount;

    constructor(
        Reputation _token
    )
        Governor("Unfakenews")
        GovernorSettings(7200 /* 1 day */, 50400 /* 1 week */, 10)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(30)
    {
        reputationToken = _token;
    }

    
    function voteFor(uint256 proposalId, uint256 reputationStake) external {
        require(state(proposalId) == ProposalState.Active, "Voting is not active for this proposal");
        require(reputationStake > 0, "Invalid reputation stake");

        Proposal storage proposal = _proposals[proposalId];
        require(reputationToken.balanceOf(msg.sender) >= reputationStake, "Insufficient reputation balance");

        reputationToken.transferFrom(msg.sender, address(this), reputationStake);
        proposal.forVotes += reputationStake;
        proposal.reputationStaked[msg.sender] += reputationStake;
        proposal.votersFor.push(msg.sender);


        emit VoteCast(msg.sender, proposalId, 1, reputationStake, "Raisin blanc");
    }

    function voteAgainst(uint256 proposalId, uint256 reputationStake) external {
        require(state(proposalId) == ProposalState.Active, "Voting is not active for this proposal");
        require(reputationStake > 0, "Invalid reputation stake");

        Proposal storage proposal = _proposals[proposalId];
        require(reputationToken.balanceOf(msg.sender) >= reputationStake, "Insufficient reputation balance");

        reputationToken.transferFrom(msg.sender, address(this), reputationStake);
        proposal.againstVotes += reputationStake;
        proposal.reputationStaked[msg.sender] += reputationStake;
        proposal.votersAgainst.push(msg.sender);

        emit VoteCast(msg.sender, proposalId, 0, reputationStake, "Raisin blanc");
    }

    function _execute(uint256 proposalId) internal {
        Proposal storage proposal = _proposals[proposalId];
        proposal.executed = true;

        // Execute the proposal based on the voting results
        if (proposal.forVotes > proposal.againstVotes) {
            // Voters that voted "For" get their staked reputation back + 10%
            for (uint256 i = 0; i < proposal.votersFor.length; i++) {
                address voter = proposal.votersFor[i];
                uint256 reputationStaked = proposal.reputationStaked[voter];
                if (reputationStaked > 0) {
                    proposal.reputationStaked[voter] = 0;
                    uint256 amountToMint = reputationStaked + (reputationStaked / 10);
                    reputationToken.mint(voter, amountToMint);
                }
            }
        } else {
            // Voters that voted "Against" get their staked reputation back - 10%
            for (uint256 i = 0; i < proposal.votersAgainst.length; i++) {
                address voter = proposal.votersAgainst[i];
                uint256 reputationStaked = proposal.reputationStaked[voter];
                if (reputationStaked > 0) {
                    proposal.reputationStaked[voter] = 0;
                    uint256 amountToBurn = reputationStaked - (reputationStaked / 10);
                    reputationToken.burn(voter, amountToBurn);
                }
            }
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
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(
        uint256 blockNumber
    )
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
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

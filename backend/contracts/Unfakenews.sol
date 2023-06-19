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

    uint256 private totalEligibleVoters;

    struct Proposal {
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => uint256) reputationStaked;
        address[] votersFor;
        address[] votersAgainst;
        uint256 nftId;
    }

    mapping(uint256 => Proposal) private _proposals;
    uint256 private _proposalCount;

    event VoteRequested(uint256 proposalId, uint256 nftId);

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

    // get toal eligible voters at beginning of voting period
    function getTotalEligibleVoters() internal view returns (uint256) {

        uint256 totalAddresses = reputationToken.balanceOf(address(this));

        for (uint256 i = 0; i < totalAddresses; i++) {
            address voter = reputationToken.tokenOfOwnerByIndex(address(this), i);
            uint256 voterReputation = reputationToken.balanceOf(voter);

            if (voterReputation > 1e3) {
                totalEligibleVoters++;
            }
        }

    return totalEligibleVoters;
    }

    function requestVoteForNFT(uint256 nftId) external {

        // Perform necessary validations or checks here
        uint256 totalReputation = reputationToken.totalSupply();
        uint256 callerReputation = reputationToken.balanceOf(msg.sender);
        
        if (totalReputation > 1e6) {
            require(callerReputation >= 1e3, "Insufficient reputation");
        }

        
        // Create a new proposal
        uint256 proposalId = _createProposal();

        // Store additional information related to the NFT in the proposal, if needed
        _proposals[proposalId].nftId = nftId;

        // Emit an event to indicate that a vote has been requested for the NFT
        emit VoteRequested(proposalId, nftId);
    }

    function _createProposal() internal returns (uint256) {
        uint256 proposalId = _proposalCount;
        _proposalCount++;

        // Initialize the proposal struct and any other necessary variables
        _proposals[proposalId].forVotes = 0;
        _proposals[proposalId].againstVotes = 0;
        _proposals[proposalId].executed = false;

        // Set totalEligibleVoters to the current total number of eligible voters
        totalEligibleVoters = getTotalEligibleVoters();
        
        return proposalId;
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
        // Set the minimum voting period to 7 days
        return 7 days;
    }

    function quorum(
    )
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        // Set the quorum to 30% of the total number of eligible voters
        uint256 quorumPercentage = 30;
        uint256 quorumVotes = (totalEligibleVoters * quorumPercentage) / 100;

        return quorumVotes;
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

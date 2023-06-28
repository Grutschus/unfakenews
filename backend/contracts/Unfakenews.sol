// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// reputation possibly not implementable as seperate contract but as simple hashmap to track voter reputation mapping


import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
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

        
        return proposalId;
    }

    
    bytes public placeholder;
    
    function voteFor(uint256 proposalId, uint256 reputationStake) external {
        _countVote(proposalId, msg.sender, 1, reputationStake, placeholder);

        _castVote(proposalId, reputationStake, true);

        emit VoteCast(msg.sender, proposalId, 1, reputationStake, "Raisin blanc");
    }

    function voteAgainst(uint256 proposalId, uint256 reputationStake) external {
        _countVote(proposalId, msg.sender, 0, reputationStake, placeholder);

        _castVote(proposalId, reputationStake, false);

        emit VoteCast(msg.sender, proposalId, 0, reputationStake, "Raisin blanc");
    }

    function _castVote(uint256 proposalId, uint256 reputationStake, bool isForVote) internal {
        Proposal storage proposal = _proposals[proposalId];
        require(reputationToken.balanceOf(msg.sender) >= reputationStake, "Insufficient reputation balance");

        reputationToken.transferFrom(msg.sender, address(this), reputationStake);
        proposal.reputationStaked[msg.sender] += reputationStake;

        if (isForVote) {
            proposal.votersFor.push(msg.sender);
        } else {
            proposal.votersAgainst.push(msg.sender);
        }
    }


    function _execute(uint256 proposalId) internal {
        Proposal storage proposal = _proposals[proposalId];
        proposal.executed = true;

        uint256 forVotes = proposal.forVotes;
        uint256 againstVotes = proposal.againstVotes;

        if (forVotes > againstVotes) {
            // Voters that voted "For" get their staked reputation back + 10%
            address[] storage votersFor = proposal.votersFor;
            uint256 votersForLength = votersFor.length;
            for (uint256 i = 0; i < votersForLength; i++) {
                address voter = votersFor[i];
                uint256 reputationStaked = proposal.reputationStaked[voter];
                if (reputationStaked > 0) {
                    proposal.reputationStaked[voter] = 0;
                    uint256 amountToMint = reputationStaked + (reputationStaked / 10);
                    reputationToken.mint(voter, amountToMint); // TODO: implement bulk mint-> give function a mapping voter to amount to mint
                }
            }
        } else {
            // Voters that voted "Against" get their staked reputation back - 10%
            address[] storage votersAgainst = proposal.votersAgainst;
            uint256 votersAgainstLength = votersAgainst.length;
            for (uint256 i = 0; i < votersAgainstLength; i++) {
                address voter = votersAgainst[i];
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
    }

    function quorum(uint256 blockNumber)
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

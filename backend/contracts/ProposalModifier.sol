// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ProposalModifier {
    IERC20 private immutable reputationToken;

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

    constructor(IERC20 _token) {
        reputationToken = _token;
    }

    function castVote(
        uint256 proposalId,
        uint256 reputationStake,
        bool isForVote,
        address voter
    ) external {
        Proposal storage proposal = _proposals[proposalId];
        require(
            reputationToken.balanceOf(voter) >= reputationStake,
            "Insufficient reputation balance"
        );

        reputationToken.transferFrom(voter, address(this), reputationStake);
        proposal.reputationStaked[voter] += reputationStake;

        if (isForVote) {
            proposal.votersFor.push(voter);
        } else {
            proposal.votersAgainst.push(voter);
        }
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = _proposals[proposalId];
        proposal.executed = true;

        uint256 forVotes = proposal.forVotes;
        uint256 againstVotes = proposal.againstVotes;

        if (forVotes > againstVotes) {
            address[] storage votersFor = proposal.votersFor;
            uint256 votersForLength = votersFor.length;
            for (uint256 i = 0; i < votersForLength; i++) {
                address voter = votersFor[i];
                uint256 reputationStaked = proposal.reputationStaked[voter];
                if (reputationStaked > 0) {
                    proposal.reputationStaked[voter] = 0;
                    uint256 amountToMint = reputationStaked + (reputationStaked / 10);
                    reputationToken.transfer(voter, amountToMint);
                }
            }
        } else {
            address[] storage votersAgainst = proposal.votersAgainst;
            uint256 votersAgainstLength = votersAgainst.length;
            for (uint256 i = 0; i < votersAgainstLength; i++) {
                address voter = votersAgainst[i];
                uint256 reputationStaked = proposal.reputationStaked[voter];
                if (reputationStaked > 0) {
                    proposal.reputationStaked[voter] = 0;
                    uint256 amountToBurn = reputationStaked - (reputationStaked / 10);
                    reputationToken.transfer(address(0), amountToBurn);
                }
            }
        }
    }

    function createProposal() external returns (uint256) {
        uint256 proposalId = _proposalCount;
        _proposalCount++;

        _proposals[proposalId].forVotes = 0;
        _proposals[proposalId].againstVotes = 0;
        _proposals[proposalId].executed = false;

        return proposalId;
    }

    function getVoters(uint256 proposalID) external view returns (address[] memory, address[] memory) {
        return (_proposals[proposalID].votersFor, _proposals[proposalID].votersAgainst);
    }
}

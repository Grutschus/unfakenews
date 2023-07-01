const truffleAssert = require("truffle-assertions");
const Unfakenews = artifacts.require("Unfakenews");

/**
 * @dev 
 */
contract("Unfakenews", (accounts) => {
    const alice = accounts[1];
    const bob = accounts[2];
    let contractOwner;
    let unfakenews;

    beforeEach(async function () {
        unfakenews = await Unfakenews.deployed();
        proposalmodifier = await ProposalModifier.deployed();
        contractOwner = await unfakenews.owner();
    });

    it("a vote should be counted", async () => {
        // Call the function to request a vote for an NFT
        await contractInstance.requestVoteForNFT(123);

        // Cast a vote for the proposal
        const proposalId = contractInstance.proposalId; 
        const reputationStake_for = 10; 
        await contractInstance.voteFor(proposalId, reputationStake_for, { from: alice });

        // Replicate the above code for voteAgainst
        const reputationStake_against = 10; 
        await contractInstance.voteAgainst(proposalId, reputationStake_against, { from: bob });

        // Get the proposal's details to check the vote count
        const proposal = await contractInstance.getProposal(proposalId);

        // Perform assertions or checks on the vote count
        assert.equal(proposal.forVotes, reputationStake_for);

        // Perform assertions or checks on the vote count
        assert.equal(proposal.againstVotes, reputationStake_against);

    });


    it("when total reputation below 1e6, everyone can call vote", async () => {
        // Set total reputation below 1e6
        await contractInstance.setTotalReputation(999999);

        // Call the function to request a vote for an NFT
        const result = await contractInstance.requestVoteForNFT(123);

        // Perform assertions or checks on the result
        // For example, you can assert that the event was emitted
        assert.equal(result.logs[0].event, "VoteRequested");

        // Add additional assertions if needed

    });

    it("when total reputation above 1e6, 1e3 reputation is needed to call a vote", async () => {
        // Set total reputation above 1e6
        await contractInstance.setTotalReputation(1000001);

        // Call the function to request a vote for an NFT
        const result = await contractInstance.requestVoteForNFT(456);

        // Perform assertions or checks on the result
        // For example, you can assert that the function call failed with an appropriate error message
        assert.equal(result.receipt.status, false);
        assert.equal(result.logs.length, 0);
        assert.include(result.receipt.message, "Insufficient reputation");

        // Add additional assertions if needed

    });

    it("a called vote should be open for at least 7 days, and only close after 30% of the total reputation supply was staked", async () => {
        // Get the voting period from the contract
        const votingPeriod = await contractInstance.votingPeriod();

        // Perform assertions or checks on the voting period
        assert.equal(votingPeriod, 604800); // 7 days in seconds

        // Get the quorum numerator from the contract
        const quorumNumerator = await contractInstance.quorumNumerator();

        // Perform assertions or checks on the quorum numerator
        assert.equal(quorumNumerator, 30);

        // Call the quorum function with a block number to get the quorum value
        const blockNumber = 123; // Replace with the desired block number
        const quorumValue = await contractInstance.quorum(blockNumber);

        // Perform assertions or checks on the quorum value
        // For example, you can compare it to the expected quorum based on the total supply
        const totalSupply = await reputationToken.totalSupply(); // Assuming you have a reputationToken instance
        const expectedQuorum = (totalSupply * quorumNumerator) / 100;
        assert.equal(quorumValue, expectedQuorum);

        // Add additional assertions or checks if needed
    });

    it("after a vote ends, every voter should have their reputation updated", async () => {
        // Voted for the right outcome -> staked reputation + 10%
        // Voted for the wrong outcome -> staked reputation - 10%
        // Creator of voted item; If vote passed -> reputation + 10%; else reputation - 10%

        // Create a new proposal and simulate the voting process
        // Call the function to request a vote for an NFT
        await contractInstance.requestVoteForNFT(123);
        const proposalId = contractInstance.proposalId; 
        const votersFor = alice; // Example voters who voted "For"
        const votersAgainst = bob; // Example voters who voted "Against"

        // Set reputation staked for voters who voted "For"
        await contractInstance.voteFor(proposalId, 100, { from: alice });

        // Set reputation staked for voters who voted "Against"
        await contractInstance.voteAgainst(proposalId, 150, { from: bob });

        // Execute the proposal, should not be necessary as the proposal is executed automatically
        // await contractInstance._execute(proposalId);

        // Check reputation update for voters who voted "For"
        const forVotersReputation = [];
        for (let i = 0; i < votersFor.length; i++) {
            const voter = votersFor[i];
            const balance = await reputationToken.balanceOf(voter);
            forVotersReputation.push(balance.toNumber());
        }
        assert(equal(forVotersReputation, [90]))

        // Check reputation update for voters who voted "Against"
        const againstVotersReputation = [];
        for (let i = 0; i < votersAgainst.length; i++) {
            const voter = votersAgainst[i];
            const balance = await reputationToken.balanceOf(voter);
            againstVotersReputation.push(balance.toNumber());
        }
        assert(equal(againstVotersReputation, [165]))
    });

    it("after a vote ends, the vote should be closed", async () => {
        // Create a new proposal and simulate the voting process
        // Call the function to request a vote for an NFT
        await contractInstance.requestVoteForNFT(123);
        const proposalId = contractInstance.proposalId; 
        const votersFor = alice; // Example voters who voted "For"
        const votersAgainst = bob; // Example voters who voted "Against"

        // Set reputation staked for voters who voted "For"
        await contractInstance.voteFor(proposalId, 100, { from: alice });

        // Set reputation staked for voters who voted "Against"
        await contractInstance.voteAgainst(proposalId, 150, { from: bob });

        // Execute the proposal, should not be necessary as the proposal is executed automatically
        // await contractInstance._execute(proposalId);

        // Check if the vote is closed
        const isVoteClosed = await contractInstance.isVoteClosed(proposalId);

        // Perform assertions or checks on the `isVoteClosed` value
        assert.isTrue(isVoteClosed, "The vote is not closed");



    });

    it("after a vote, the outcome should be updated", async () => {
        // If vote passed -> outcome = true; else outcome = false
        // Create a new proposal and simulate the voting process
        // Call the function to request a vote for an NFT
        await contractInstance.requestVoteForNFT(123);
        const proposalId = contractInstance.proposalId; 
        const votersFor = alice; // Example voters who voted "For"
        const votersAgainst = bob; // Example voters who voted "Against"

        // Set reputation staked for voters who voted "For"
        await contractInstance.voteFor(proposalId, 100, { from: alice });

        // Set reputation staked for voters who voted "Against"
        await contractInstance.voteAgainst(proposalId, 150, { from: bob });

        // Execute the proposal, should not be necessary as the proposal is executed automatically
        // await contractInstance._execute(proposalId);

        // Check the outcome after the proposal execution
        const outcome = await contractInstance.outcome(proposalId);

        // Perform assertions or checks on the `outcome` value
        // If the vote passed, the outcome should be true; otherwise, it should be false
        // Replace the condition with the appropriate check based on your contract's logic
        assert.isFalse(outcome, "The outcome is not as expected");



    });



})

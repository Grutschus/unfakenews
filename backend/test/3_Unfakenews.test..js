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
        contractOwner = await unfakenews.owner();
    });

    it("a vote should be counted", async () => {
        // Only when vote is open
    });


    it("when total reputation below 1e6, everyone can call vote", async () => {

    });

    it("when total reputation above 1e6, 1e3 reputation is needed to call a vote", async () => {

    });

    it("a called vote should be open for at least 7 days, and only close after 30% have voted", async () => {

    });

    it("after a vote, every voter should have their reputation updated", async () => {
        // Voted for the right outcome -> staked reputation + 10%
        // Voted for the wrong outcome -> staked reputation - 10%
        // Creator of voted item; If vote passed -> reputation + 10%; else reputation - 10%
    });

    it("after a vote, the vote should be closed", async () => {

    });

    it("after a vote, the outcome should be updated", async () => {
        // If vote passed -> outcome = true; else outcome = false
    });



})

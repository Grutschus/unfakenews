const truffleAssert = require("truffle-assertions");
const Reputation = artifacts.require("Reputation");

/**
 * @dev 
 */
contract("Reputation", (accounts) => {
    const alice = accounts[1];
    const bob = accounts[2];
    let contractOwner;
    let reputation;

    beforeEach(async function () {
        reputation = await Reputation.deployed();
        contractOwner = await reputation.owner();
    });

    it("reputation should be mintable only by contract owner", async () => {
        await truffleAssert.reverts(
            reputation.mint(alice, 10, { from: alice }),
            "Ownable: caller is not the owner"
        );

        await reputation.mint(alice, 10, { from: contractOwner });
        const balance = await reputation.balanceOf(alice);
        assert.equal(balance, 10, "balance should be 10");

        // burn the minted reputation to reset the state
        await reputation.burn(alice, 10, { from: contractOwner });
    });

    it("reputation should be burnable only by contract owner", async () => {
        await reputation.mint(alice, 10, { from: contractOwner });

        // Negative test
        await truffleAssert.reverts(
            reputation.burn(alice, 10, { from: alice }),
            "Ownable: caller is not the owner"
        );

        // Positive test
        await reputation.burn(alice, 10, { from: contractOwner });
        const balance = (await reputation.balanceOf(alice)).toNumber();
        assert.equal(balance, 0, "balance should be 0");
    });

    it("reputation should not be transferable", async () => {
        await reputation.mint(alice, 10, { from: contractOwner });

        await truffleAssert.reverts(
            reputation.transfer(bob, 10, { from: alice }),
            "Reputation: Token transfers are not allowed"
        );

        // burn the minted reputation to reset the state
        await reputation.burn(alice, 10, { from: contractOwner });
    });



    // TODO: Add additional tests


})

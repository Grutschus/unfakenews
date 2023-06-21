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

    it("reputation should be transferable", async () => {
        // Mint reputation tokens to Alice
        const amount = 10;
        await reputation.mint(alice, amount, { from: contractOwner });

        // Check Alice's balance before the transfer
        const aliceBalanceBefore = await reputation.balanceOf(alice);

        // Transfer reputation from Alice to the contract owner
        await reputation.transfer(contractOwner, amount, { from: alice });

        // Check Alice's balance after the transfer
        const aliceBalanceAfter = await reputation.balanceOf(alice);

        // Check the contract owner's balance after the transfer
        const contractOwnerBalance = await reputation.balanceOf(contractOwner);

        // Assert the balances are correct
        assert.equal(aliceBalanceBefore - amount, aliceBalanceAfter, "Alice's balance is incorrect");
        assert.equal(contractOwnerBalance, amount, "Contract owner's balance is incorrect");
    });
    



    // TODO: Add additional tests


})

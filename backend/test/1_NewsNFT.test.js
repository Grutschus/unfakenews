const truffleAssert = require("truffle-assertions");
const NewsNFT = artifacts.require("NewsNFT");

/**
 * @dev Here we are testing functionality related to minted NFTS.
 * This includes minting itself, transferring, voting, and
 * verification of the minted token. 
 * Testing of the NewsNFT contract itself, i.e. ownerhsip of the contract,
 * permissions, is done in Solidity.
 */
contract("NewsNFT", (accounts) => {
    const alice = accounts[1];
    const bob = accounts[2];
    let newsNFT;
    let contractOwner;
    let aliceTokenID;
    let bobTokenID;

    beforeEach(async function () {
        newsNFT = await NewsNFT.deployed();
        contractOwner = await newsNFT.owner();
        aliceTokenID = (await newsNFT.createNewsItem("alices news", { from: alice })).logs[0].args.tokenId.toNumber();
        bobTokenID = (await newsNFT.createNewsItem("bobs news", { from: bob })).logs[0].args.tokenId.toNumber();
    });

    it("minter should be owner of NFTs", async () => {
        const tokenOwner = await newsNFT.ownerOf(aliceTokenID);
        assert.equal(tokenOwner, alice, "owner should be minter");
    });

    it("token owner cannot transfer NFTs", async () => {
        // transfer NFT
        await truffleAssert.reverts(
            newsNFT.safeTransferFrom(alice, bob, aliceTokenID, { from: alice }),
            "NewsNFT: Token transfers are not allowed"
        );
    });

    it("verification state should default to unverified", async () => {
        const state = await newsNFT.getVerificationState(aliceTokenID);

        assert.equal(state, 0, "state should be unverified (0)");
    });

    it("verification state can only be set by contract owner", async () => {
        await truffleAssert.reverts(
            newsNFT.setVerificationState(aliceTokenID, 1, { from: alice }),
            "Ownable: caller is not the owner"
        );
        await newsNFT.setVerificationState(aliceTokenID, 1, { from: contractOwner });
        const state = await newsNFT.getVerificationState(aliceTokenID);
        assert.equal(state, 1, "state should be verified (1)");
    });


    it("given a URI, the correct tokenID can be retrieved", async () => {
        // Get the tokenID for the URI
    });
})

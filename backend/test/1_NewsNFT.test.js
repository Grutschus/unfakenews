const truffleAssert = require("truffle-assertions");
const NewsNFT = artifacts.require("NewsNFT");

contract("NewsNFT", (accounts) => {
    it("anyone should be able to mint NFTs", async () => {
        const newsNFT = await NewsNFT.deployed();
        const owner = accounts[0];

        const transaction = await newsNFT.safeMint("test");
        const logs = transaction.logs;
        const tokenId = logs[0].args.tokenId.toNumber();


        assert.equal(tokenId, 0, "tokenId should be 0");
    });

    it("minter should be owner of NFTs", async () => {
        const newsNFT = await NewsNFT.deployed();
        const owner = accounts[0];

        // mint NFT
        await newsNFT.safeMint("test");

        // check owner
        const tokenOwner = await newsNFT.ownerOf(0);

        assert.equal(tokenOwner, owner, "owner should be minter");
    });

    it("owner cannot transfer NFTs", async () => {
        const newsNFT = await NewsNFT.deployed();
        const owner = accounts[0];
        const receiver = accounts[1];

        // mint NFT
        await newsNFT.safeMint("test", { from: owner });

        // transfer NFT
        await truffleAssert.reverts(
            newsNFT.safeTransferFrom(owner, receiver, 0, { from: owner }),
            "NewsNFT: Token transfers are not allowed"
        );

    });

})

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NewsNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NewsNFT", "NNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        // TODO: Replace with IPFS hash
        return "http://placehold.it/120x120&text=";
    }

    /**
     * @dev Creates a new NewsNFT and mints it to the caller.
     * @param uri The URI of the token metadata.
     */
    function safeMint(string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        // TODO: Store Metadata onchain
        _setTokenURI(tokenId, uri);
    }

    /**
     * @dev Disables transfers. See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (from != address(0)) {
            // Not a mint
            revert("NewsNFT: Token transfers are not allowed");
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
     * @dev
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}

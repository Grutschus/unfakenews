// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NewsNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => VerificationState) private _verificationStates;

    enum VerificationState {
        Unverified,
        VerifiedTrue,
        VerifiedFalse
    }

    constructor() ERC721("NewsNFT", "NNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        // TODO: Replace with IPFS
        return "http://placehold.it/120x120&text=";
    }

    /**
     * @dev Returns the verification state of the NewsNFT.
     * @param tokenId ID of the token to check
     */
    function getVerificationState(
        uint256 tokenId
    ) public view returns (VerificationState) {
        require(
            _exists(tokenId),
            "NewsNFT: VerificationState query for nonexistent token"
        );
        return _verificationStates[tokenId];
    }

    /**
     * @dev Sets the verification state of the NewsNFT.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function setVerificationState(
        uint256 tokenId,
        VerificationState state
    ) public onlyOwner {
        _setVerificationState(tokenId, state);
    }

    function _setVerificationState(
        uint256 tokenId,
        VerificationState state
    ) internal {
        require(
            _exists(tokenId),
            "NewsNFT: VerificationState set of nonexistent token"
        );
        _verificationStates[tokenId] = state;
    }

    /**
     * @dev Creates a new NewsNFT and mints it to the caller.
     * @param file_hash IPFS hash of the metadata file
     */
    function createNewsItem(string memory file_hash) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, file_hash);
        _setVerificationState(tokenId, VerificationState.Unverified);
        return tokenId;
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

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}

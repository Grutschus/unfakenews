// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../contracts/NewsNFT.sol";

/**
 * Contract that serves as a dummy owner of a NewsNFT
 * for testing.
 */
contract NewsNFTOwner is ERC721Holder {
    uint256 public tokenID;

    constructor(NewsNFT newsNFT) {
        tokenID = newsNFT.createNewsItem("test");
    }
}

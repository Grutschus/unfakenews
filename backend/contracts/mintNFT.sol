// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract mintNFT is ERC721URIStorage, Ownable {
  constructor() ERC721("Unfake News", "UFN") {
  }

  function mint(address _to, uint256 _tokenId, string memory _tokenURI) external onlyOwner {
    _safeMint(_to, _tokenId);
    _setTokenURI(_tokenId, _tokenURI);
  }
}

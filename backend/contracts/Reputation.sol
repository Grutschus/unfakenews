// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Reputation is ERC20, Ownable {
    constructor() ERC20("Reputation", "RPT") {}

    /**
     * @dev We don't need fractions of reputation
     */
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);

        // Disable transfers, only minting and burning allowed
        if (from != address(0) && to != address(0)) {
            revert("Reputation: Token transfers are not allowed");
        }
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}

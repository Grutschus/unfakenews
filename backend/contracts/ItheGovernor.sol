// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the Governor. Can be imported by Reputation.sol to ckeck, if it is called by the Governor.
 */

interface ItheGovernor {
    function isGovernor() external view returns (bool);
}
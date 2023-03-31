// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract VoteStorage {
    /// @dev Stores voting power at a block.
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    bytes32 internal constant _DELEGATION_TYPEHASH = keccak256('Delegation(address delegatee,uint256 nonce,uint256 expiry)');

    /// @dev Mapping of delegates addresses
    mapping(address => address) internal _delegates;

    /// @dev Array of checkpoints of every user
    mapping(address => Checkpoint[]) internal _checkpoints;
    Checkpoint[] internal _totalSupplyCheckpoints;
}

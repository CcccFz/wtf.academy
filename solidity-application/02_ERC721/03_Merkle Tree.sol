// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";

library MerkleProof {
    function veriry(bytes32 root, bytes32 leaf, bytes32[] memory proof) external pure returns (bool) {
        return root == _computeRoot(leaf, proof);
    }

    function _computeRoot(bytes32 leaf, bytes32[] memory proof) private pure returns (bytes32) {
        bytes32 computeHash = leaf;
        for (uint i=0; i<proof.length; i++) {
            computeHash = _hashPair(computeHash, proof[i]);
        }
        return computeHash;
    }

    function _hashPair(bytes32 x, bytes32 y) private pure returns (bytes32) {
        return x <= y ? keccak256(abi.encodePacked(x, y)) : keccak256(abi.encodePacked(y, x));
    }
}

contract MerkleTree is ERC721 {
    bytes32 private _root;
    mapping (address => bool) mintedAddrs;

    constructor(string memory name, string memory symbol, bytes32 root) ERC721(name, symbol) {
        _root = root;
    }

    function mint(address to, uint32 tokenId, bytes32[] calldata proof) external {
        require(!mintedAddrs[to], "Already minted !");
        require(_veriry(to, proof), "Invalid merkle proof");

        _mint(to, tokenId);
        mintedAddrs[to] = true;
    }

    function _veriry(address to, bytes32[] memory proof) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(to));
        return MerkleProof.veriry(_root, leaf, proof);
    }
}
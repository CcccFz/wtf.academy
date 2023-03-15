// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";

library ECDSA {
    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) external pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address) {
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
        return ecrecover(_msgHash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) external pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract SignatureNFT is ERC721 {
    address immutable private signer;
    mapping (address => bool) private mintedAddrs;

    constructor(string memory _name, string memory _symbol, address _signer) ERC721(_name, _symbol) {
        signer = _signer;
    }

    function getMessageHash(address _account, uint256 _tokenId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) internal view returns (bool) {
        return ECDSA.verify(_msgHash, _signature, signer);
    }

    function mint(address _account, uint256 _tokenId, bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _signedMsgHash = ECDSA.toEthSignedMessageHash(_msgHash);
        require(verify(_signedMsgHash, _signature), "Invalid signature");
        require(!mintedAddrs[_account], "Already minted!");

        _mint(_account, _tokenId);
        mintedAddrs[_account] = true;
    }
}
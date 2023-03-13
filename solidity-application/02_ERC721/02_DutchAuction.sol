// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTOIN_SIZE = 1000;
    uint256 public constant AUCTION_START_PRICE = 1 ether;
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;
    uint256 public constant AUCTION_TIME = 5 minutes;
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;
    uint256 public constant AUCTION_DROP_PER_STEP = 
        (AUCTION_START_PRICE-AUCTION_END_PRICE) / (AUCTION_TIME/AUCTION_DROP_INTERVAL);
    
    uint256 public auctionStartTime;
    string private _baseTokenURI;
    uint256[] private _allTokens;

    constructor() ERC721("Dutch Auctoin", "Dutch Auctoin") {
        auctionStartTime = block.timestamp;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }  

    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    function setAuctionStartTime(uint256 startTime) external onlyOwner {
        auctionStartTime = startTime;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdraw() external onlyOwner {
        (bool isSuccess, ) = msg.sender.call{value: address(this).balance}("");
        require(isSuccess, "Withdraw failed.");
    }

    function getPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
            return AUCTION_START_PRICE;
        } else if (block.timestamp >= auctionStartTime + AUCTION_TIME ) {
            return AUCTION_END_PRICE;
        } else {
            return AUCTION_START_PRICE - AUCTION_DROP_PER_STEP * ((block.timestamp-auctionStartTime)/AUCTION_DROP_INTERVAL);
        }
    }

    function auctionMint(uint256 quantity) external payable {
        uint256 startTime = auctionStartTime;
        require(startTime != 0 && block.timestamp >= startTime, "sale has not started yet");
        require(_allTokens.length+quantity <= COLLECTOIN_SIZE, "not enough remaining reserved for auction to support desired mint amount");

        uint256 cost = getPrice() * quantity;
        require(msg.value >= cost, "Need to send more ETH.");

        for (uint i=0; i < quantity; i++) {
            uint256 tokenId = totalSupply();
            _mint(msg.sender, tokenId);
            _addTokenToAllTokensEnumeration(tokenId);
        }

        if (msg.value > cost) {
            // todo: handle return
            msg.sender.call{value: msg.value - cost}("");
        }
    } 
}

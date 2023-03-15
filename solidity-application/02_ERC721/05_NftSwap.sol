// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./01_Ape.sol";

contract NftSwap is IERC721Receiver {
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    struct Order {
        address owner;
        uint256 price;
    }

    // [nftAddr][tokenId] => order
    mapping (address => mapping (uint256 => Order)) public orderList;

    receive() external payable {}

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) { return IERC721Receiver.onERC721Received.selector; }

    function list(address nftAddr, uint256 tokenId, uint256 price) external {
        IERC721 nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == msg.sender, "Need Owner!");
        require(nft.getApproved(tokenId) == address(this), "Need Approved!");
        require(price > 0);

        Order storage order = orderList[nftAddr][tokenId];
        order.owner = msg.sender;
        order.price = price;

        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        emit List(msg.sender, nftAddr, tokenId, price);
    }

    function revoke(address nftAddr, uint256 tokenId) external {
        Order storage order = orderList[nftAddr][tokenId];
        require(order.owner == msg.sender, "Need Owner!");

        IERC721 nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == address(this), "Invalid Order!");
    
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        delete orderList[nftAddr][tokenId];

        emit Revoke(msg.sender, nftAddr, tokenId);
    }

    function update(address nftAddr, uint256 tokenId, uint256 newPrice) external {
        Order storage order = orderList[nftAddr][tokenId];
        require(order.owner == msg.sender, "Need Owner!");
        require(newPrice > 0);

        IERC721 nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == address(this), "Invalid Order!");        

        order.price = newPrice;
        emit Update(msg.sender, nftAddr, tokenId, newPrice);
    }

    function purchase(address nftAddr, uint256 tokenId) external payable {
        Order storage order = orderList[nftAddr][tokenId];
        require(msg.value >= order.price, "Need more Eth!");

        IERC721 nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == address(this), "Invalid Order!");

        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        payable(order.owner).transfer(order.price);
        if (msg.value > order.price) {
            payable(msg.sender).transfer(msg.value-order.price);
        }

        delete orderList[nftAddr][tokenId];
        emit Purchase(msg.sender, nftAddr, tokenId, order.price);
    }
}
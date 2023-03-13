// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './01_IERC20.sol';

contract Airdrop {
    
    function multiTransferToken(IERC20 token, address[] calldata addrs, uint256[] calldata amounts) external {
        require(addrs.length == amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");
        require(token.allowance(msg.sender, address(this)) >= sum(amounts), "Need Approve ERC20 token");
        
        for (uint i=0; i < addrs.length; i++) {
            token.transferFrom(msg.sender, addrs[i], amounts[i]);
        }
    }

    function multiTransferETH(address payable[] calldata addrs, uint256[] calldata amounts) public payable {
        require(addrs.length == amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");
        require(msg.value >= sum(amounts), "Transfer amount error");

        for (uint i=0; i < addrs.length; i++) {
            // addrs[i].transfer(amounts[i]);
            (bool isOk,) = addrs[i].call{value: amounts[i]}("");
        }
    }

    function sum(uint256[] calldata amounts) private pure returns (uint256 total) {
        for (uint i=0; i < amounts.length; i++) {
            total += amounts[i];
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './01_IERC20.sol';

contract Faucet {
    IERC20 token;
    uint256 public amountAllowed = 100;
    mapping (address => bool) requestedAddress;

    event SendEvent(address indexed account, uint256 amount);

    constructor(IERC20 addr) {
        token = addr;
    }

    function requestTokens() external returns (bool) {
        require(!requestedAddress[msg.sender], "Can't Request Multiple Times!");
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!");

        token.transfer(msg.sender, amountAllowed);
        requestedAddress[msg.sender] = true;
        
        emit SendEvent(msg.sender, amountAllowed);
        return true;
    }    
}
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

contract DeleteContract {
    uint public value = 10;

    constructor() payable {
        
    }

    receive() external payable {

    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function deleteContract() external {
        // 已废除
        selfdestruct(payable(msg.sender));
    }
}
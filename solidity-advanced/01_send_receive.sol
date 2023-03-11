// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

contract SendETH {
    event ReceiveLog(address indexed _form, uint amount, uint gas);
    event SendLog(address indexed _to, uint amount, uint gas);

    error CallFailed();

    constructor() payable {
        emit ReceiveLog(msg.sender, msg.value, gasleft());
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function sendEth(address _to, uint256 amount) public payable {
        (bool isOk, ) = _to.call{value: amount}("");
        if (!isOk) {
            revert CallFailed();
        }
    }
}

contract ReceiveETH {
    event ReceiveLog(address indexed _form, uint amount, uint gas);

    constructor() payable {
        
    }

    receive() external payable {
        emit ReceiveLog(msg.sender, msg.value, gasleft());
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
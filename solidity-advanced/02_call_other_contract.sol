// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

interface IOtherContract {
    function getX() external view returns (uint);
    function setX(uint x) external payable;
}

contract OtherContract is IOtherContract {
    uint256 _x;

    event ReceiveEthLog(address indexed _from, uint amount, uint gas);
    
    function getX() external view override returns (uint256) {
        return _x;
    }

    function setX(uint256 x) external payable override {
        _x = x;
        if (msg.value > 0) {
            emit ReceiveEthLog(msg.sender, msg.value, gasleft());
        }
    }
}

contract MyContract {
    event Response(bool isOk, bytes data);

    constructor() payable {}

    function callOtherSetX(address _addr, uint256 x, uint amount) external {
        if (amount > 0) {
            IOtherContract(_addr).setX{value: amount}(x);
        } else {
            IOtherContract otherContract = IOtherContract(_addr);
            otherContract.setX(x);
        }
    }

    function callOtherGetX(IOtherContract _addr) external view returns (uint256) {
        return _addr.getX();
    }

    function callUnknowContractSetX(address _addr, uint256 x, uint amount) external {
        (bool isOk, bytes memory data) =  _addr.call{value: amount}(
            abi.encodeWithSignature("setX(uint256)", x)
        );
        emit Response(isOk, data);
    }

    function callUnknowContractGetX(address _addr) external returns (uint256) {
        (bool isOk, bytes memory data) = _addr.call(
            abi.encodeWithSignature("getX()")
        );
        emit Response(isOk, data);
        return abi.decode(data, (uint256));
    }
}
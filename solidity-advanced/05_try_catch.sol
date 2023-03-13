// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

contract OnlyEvent {
    constructor(uint a) {
        require(a != 0, "invalid number");
        assert(a != 1);
    }

    function onlyEvent(uint a) external pure returns (bool isSuccess) {
        require(a % 2 == 0, "Ups! Reverting");
        isSuccess = true;
    }
}

contract TryContract {
    event SuccessEvent();
    event CatchEvent(string message);
    event CatchByte(bytes data);

    OnlyEvent even;

    constructor() {
        even = new OnlyEvent(2);
    }

    function execute(uint a) external returns (bool isSuccess) {
        try new OnlyEvent(a) returns (OnlyEvent _even) {
            emit SuccessEvent();
            isSuccess = _even.onlyEvent(a);
        } catch Error(string memory reason) {
            emit CatchEvent(reason);
        } catch (bytes memory reason) {
            emit CatchByte(reason);
        }
    }
}
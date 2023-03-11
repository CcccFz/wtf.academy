// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

contract Pair {
    address public factory;
    address public token0;
    address public token1;

    constructor() payable {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {
        require(factory == msg.sender);
        token0 = _token0;
        token1 = _token1;
    }
}

contract PairFactory {
    mapping (address => mapping (address => address)) public getPair;
    address[] public allPairs;

    function createPair(address _token0, address _token1) external returns (address pairAddr) {
        Pair pair = new Pair();
        pair.initialize(_token0, _token1);
        pairAddr = address(pair);

        allPairs.push(pairAddr);
        getPair[_token0][_token1] = pairAddr;
        getPair[_token1][_token0] = pairAddr;

        return pairAddr;
    }

    function createPair2(address _token0, address _token1) external returns (address pairAddr) {
        require(_token0 != _token1, "IDENTICAL_ADDRESSES");
        (_token0, _token1) = (_token0 <= _token1) ? (_token0, _token1) : (_token1, _token0);
        bytes32 salt = keccak256(abi.encodePacked(_token0, _token1));

        Pair pair = new Pair{salt: salt}();
        pair.initialize(_token0, _token1);
        pairAddr = address(pair);

        allPairs.push(pairAddr);
        getPair[_token0][_token1] = pairAddr;
        getPair[_token1][_token0] = pairAddr;
    }

    function calculateAddr(address _token0, address _token1) external view returns (address pairAddr) {
        require(_token0 != _token1, "IDENTICAL_ADDRESSES");
        (_token0, _token1) = (_token0 <= _token1) ? (_token0, _token1) : (_token1, _token0);
        bytes32 salt = keccak256(abi.encodePacked(_token0, _token1));

        pairAddr = address(
            uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff), address(this), salt, keccak256(type(Pair).creationCode)
            ))))
        );
    }
}
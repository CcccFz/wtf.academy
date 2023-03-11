// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

contract Name {
    constructor() {
        
    }

    function insert_sort(uint[] memory nums) public pure returns (uint[] memory) {
        for (uint i = 1; i < nums.length; i++) {
            uint num = nums[i];
            uint j = i;
            while (j > 0 && num < nums[j-1]) {
                nums[j] = nums[j-1];
                j--;
            }
            nums[j] = num;
        }
        return (nums);
    }
}
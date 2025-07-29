// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogicV2 {
    uint256 public value;
    
    function initialize(uint256 _value) public {
        require(value == 0, "Already initialized");
        value = _value;
    }
    
    function increment() public {
        value += 1;
    }
    
    function decrement() public {
        value -= 1;
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }

    
    function double() public {
        value *= 2;
    }
}
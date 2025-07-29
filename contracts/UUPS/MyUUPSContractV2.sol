// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyUUPSContractV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public value;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    // 保持相同的初始化函数签名
    function initialize(uint256 _value) public reinitializer(2) {
        __Ownable_init();
        value = _value;
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    function increment() public {
        value += 1;
    }
    
    // 新增功能
    function decrement() public {
        value -= 1;
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }
    
    // 新增功能
    function double() public {
        value *= 2;
    }
}
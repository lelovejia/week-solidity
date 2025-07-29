// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyUUPSContractV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public value;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // 禁用直接部署
    }
    
    function initialize(uint256 _value) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        value = _value;
    }
    
    // UUPS 升级授权函数
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    function increment() public {
        value += 1;
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }
}
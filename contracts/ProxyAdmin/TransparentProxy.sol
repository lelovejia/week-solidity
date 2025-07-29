// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// 内联定义StorageSlot库
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// 内联定义Address库
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
contract TransparentProxy {
    // 实现合约地址存储在特定槽位以避免冲突
    // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 private constant _IMPLEMENTATION_SLOT = 
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    // 管理员地址存储在特定槽位
    // bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 private constant _ADMIN_SLOT = 
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor(address implementation_) {
        _setAdmin(msg.sender);
        _setImplementation(implementation_);
    }

    // 管理员修改函数
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    // 获取管理员地址
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    // 获取实现合约地址
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _getImplementation();
    }

    // 升级实现合约
    function upgradeTo(address newImplementation) external ifAdmin {
        _setImplementation(newImplementation);
    }

    // 更改管理员
    function changeAdmin(address newAdmin) external ifAdmin {
        _setAdmin(newAdmin);
    }

    // 回退函数 - 将调用委托给实现合约
    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    // 内部回退实现
    function _fallback() internal {
        _delegate(_getImplementation());
    }

    // 内部委托调用
    function _delegate(address implementation_) internal {
        assembly {
            // 复制calldata到内存
            calldatacopy(0, 0, calldatasize())

            // 执行delegatecall
            let result := delegatecall(
                gas(), 
                implementation_, 
                0, 
                calldatasize(), 
                0, 
                0
            )

            // 复制返回数据到内存
            returndatacopy(0, 0, returndatasize())

            // 处理结果
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // 获取实现合约地址
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    // 设置实现合约地址
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    // 获取管理员地址
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    // 设置管理员地址
    function _setAdmin(address newAdmin) private {
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
}
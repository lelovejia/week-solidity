// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 private _nextTokenId; // 自增TokenID计数器
    address public owner; // 合约所有者

    constructor() ERC721("MyNFT", "ANFT") {
        owner = msg.sender; // 部署时设置所有者
    }

    // 铸造新NFT（仅所有者可调用）
    function safeMint(address to) public {
        require(msg.sender == owner, "Only owner can mint");
        uint256 tokenId = _nextTokenId++; // 分配新ID
        _safeMint(to, tokenId); // 安全铸造
    }

    // 查询当前TokenID计数
    function getCurrentTokenId() public view returns (uint256) {
        return _nextTokenId; // 返回下一个可用ID
    }
}
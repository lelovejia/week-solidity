// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Auction.sol";

contract AuctionFactory {
    // 按卖家地址索引的拍卖列表
    mapping(address => address[]) public auctionsBySeller;
    address[] public allAuctions; // 所有拍卖地址

    event AuctionCreated(address seller, address indexed auction);

    // 创建新拍卖实例
    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        address _paymentToken,
        address _priceFeed
    ) external returns (address) {
        Auction auction = new Auction(); // 部署新合约
        auction.initialize(
            msg.sender,
            _nftContract,
            _tokenId,
            _paymentToken,
            _priceFeed
        );
        auctionsBySeller[msg.sender].push(address(auction));
        allAuctions.push(address(auction));
        emit AuctionCreated(msg.sender, address(auction));
        return address(auction);
    }

    // 获取总拍卖数量
    function getAuctionsCount() external view returns (uint256) {
        return allAuctions.length;
    }
}

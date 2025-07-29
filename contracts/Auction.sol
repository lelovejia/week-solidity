// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction is UUPSUpgradeable {
    address public seller; // NFT所有者
    address public nftContract; // NFT合约地址
    uint256 public tokenId; // 拍卖的TokenID
    address public paymentToken; // 支付代币地址
    uint256 public highestBid; // 当前最高出价
    address public highestBidder; // 最高出价者
    bool public ended; // 拍卖结束标志
    AggregatorV3Interface internal priceFeed; // Chainlink预言机
/*  */
    event AuctionEnded(address winner, uint256 amount); // 拍卖结束事件

    // 初始化函数（UUPS模式替代构造函数）
    function initialize(
        address _seller,
        address _nftContract,
        uint256 _tokenId,
        address _paymentToken,
        address _priceFeed
    ) public initializer {
        seller = _seller;
        nftContract = _nftContract;
        tokenId = _tokenId;
        paymentToken = _paymentToken;
        priceFeed = AggregatorV3Interface(_priceFeed); // 初始化预言机
    }

    // 参与竞标（接收ETH支付）
    function bid() external payable {
        require(!ended, "Auction already ended");
        require(msg.value > highestBid, "Bid too low");

        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid); // 退回前一个出价
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
    }

    // 结束拍卖并结算
    function endAuction() external {
        require(msg.sender == seller, "Only seller can end");
        require(!ended, "Already ended");

        ended = true;
        IERC721(nftContract).safeTransferFrom(msg.sender, highestBidder, tokenId);
        payable(seller).transfer(highestBid);

        emit AuctionEnded(highestBidder, highestBid);
    }

    // 获取当前最高出价的美元价值
    function getPriceInUSD() public view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price) * highestBid / 1e18; // 价格*数量/精度
    }

    // UUPS升级授权（仅所有者可调用）
    function _authorizeUpgrade(address) internal override {}
}
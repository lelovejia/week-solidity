const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("NFT Auction", function () {
    it("完整流程测试", async function () {
        // 1. 准备测试账户
        const [owner, bidder] = await ethers.getSigners();
        console.log(`测试账户地址owner: ${owner.address}`);
        console.log(`测试账户地址bidder: ${bidder.address}`);
        // 2. 部署NFT合约并铸造
        const NFT = await ethers.getContractFactory("MyNFT");
        const nft = await NFT.deploy();
        await nft.waitForDeployment();
        await nft.safeMint(owner.address);
        const nftAddress = await nft.getAddress();
        console.log(`NFT合约地址: ${nftAddress}`);
        // 3. 部署工厂合约
        const Factory = await ethers.getContractFactory("AuctionFactory");
        const factory = await Factory.deploy();
        const factoryAddress = await factory.getAddress();
        console.log(`工厂合约地址: ${factoryAddress}`);


        // 4. 创建拍卖实例
        const tx = await factory.createAuction(
            nftAddress,
            0, // 首个NFT
            "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", // ETH支付 地址要为字符串
            "0x694AA1769357215DE4FAC081bf1f309aDC325306" // Sepolia ETH/USD
        );
        const receipt = await tx.wait();//等待交易确认
        // const eventLog = receipt.logs.find(log => log.address === factoryAddress);
        // let auctionAddr;
        // if (eventLog) {
        //     auctionAddr = "0X" + eventLog.topics[1].slice(26);
        // }
        const event = factory.interface.parseLog(receipt.logs[1]);
        const auctionAddr = event.args.auction;


        console.log(`工厂合约生成的Auction地址: ${auctionAddr}`);
        const auction = await ethers.getContractAt("Auction", auctionAddr);
        // 5. 模拟出价
        await auction.connect(bidder).bid({ value: ethers.parseEther("0.01") });    // 出价0.01 ETH                
        expect(await auction.highestBid()).to.equal(ethers.parseEther("0.01"));

        // 6. Owner 授权拍卖合约
        await nft.connect(owner).approve(auctionAddr, 0);

        // 7. 结束拍卖并验证
        await auction.connect(owner).endAuction();
        expect(await nft.ownerOf(0)).to.equal(bidder.address); // NFT应转移
    });
});

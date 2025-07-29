const { ethers, upgrades } = require("hardhat");

async function main() {
    // 1. 部署NFT合约
    const NFT = await ethers.getContractFactory("MyNFT");
    const nft = await NFT.deploy();
    console.log(`NFT合约地址: ${nft.address}`);

    // 2. 部署工厂合约
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    const factory = await AuctionFactory.deploy();
    console.log(`工厂合约地址: ${factory.address}`);

    // 3. 准备可升级拍卖合约
    const Auction = await ethers.getContractFactory("Auction");
    const auctionImpl = await upgrades.deployImplementation(Auction);
    console.log(`拍卖逻辑合约地址: ${auctionImpl}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

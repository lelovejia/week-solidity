// 引入必要的插件
require("@nomicfoundation/hardhat-toolbox"); // Hardhat基础工具包
require("@openzeppelin/hardhat-upgrades"); // 合约升级插件
require("hardhat-deploy"); // 合约部署工具
require("dotenv").config(); // 环境变量加载

module.exports = {
    solidity: "0.8.28", // Solidity编译器版本
    networks: {
        sepolia: { // Sepolia测试网配置
            url: process.env.ALCHEMY_SEPOLIA_URL, // 节点服务URL
            accounts: [process.env.PK], // 部署账户
            // chainId: 11155111 // 链ID
        }
    },
    namedAccounts: { // 命名账户配置
        deployer: 0, // 默认使用第一个账户部署
        user: 1,
    },
    // etherscan: { // 区块浏览器验证
    //     apiKey: process.env.ETHERSCAN_API_KEY
    // }
};

// test/TransparentProxy.test.js
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Transparent Proxy", function () {
    let proxy;
    let logicV1;
    let logicV2;
    let admin;
    let user;

    before(async function () {
        [admin, user] = await ethers.getSigners();

        // 部署逻辑合约V1
        const LogicV1 = await ethers.getContractFactory("LogicV1");
        logicV1 = await LogicV1.deploy();
        await logicV1.waitForDeployment();
        console.log("Value from logicV1:", await logicV1.getValue());
        console.log("Address from logicV1:", await logicV1.getAddress());

        // 部署代理合约
        const TransparentProxy = await ethers.getContractFactory("TransparentProxy");
        proxy = await TransparentProxy.deploy(await logicV1.getAddress());
        await proxy.waitForDeployment();
        console.log("Address from proxy:", await proxy.getAddress());

        // 通过代理初始化
        const proxyAsLogicV1 = await ethers.getContractAt("LogicV1", await proxy.getAddress());
        await proxyAsLogicV1.initialize(42);
        console.log("Address from proxy:", await proxyAsLogicV1.getAddress());
        console.log("Value from proxy:", await proxyAsLogicV1.getValue());
    });

    it("should initialize correctly", async function () {
        const proxyAsLogicV1 = await ethers.getContractAt("LogicV1", await proxy.getAddress());
        expect(await proxyAsLogicV1.getValue()).to.equal(42);
        console.log("should initialize correctly", await proxyAsLogicV1.getValue());
    });

    it("should allow increment through proxy", async function () {
        const proxyAsLogicV1 = await ethers.getContractAt("LogicV1", await proxy.getAddress());
        await proxyAsLogicV1.increment();
        expect(await proxyAsLogicV1.getValue()).to.equal(43);
        console.log("should allow increment through proxy", await proxyAsLogicV1.getValue());
    });

    it("should not allow non-admin to upgrade", async function () {
        const proxyAsProxy = await ethers.getContractAt("TransparentProxy", await proxy.getAddress());
        await expect(proxyAsProxy.connect(user).upgradeTo(ethers.ZeroAddress))
            .to.be.revertedWith("Only admin can upgrade");
    });

    it("should upgrade to V2 correctly", async function () {
        // 部署逻辑合约V2
        const LogicV2 = await ethers.getContractFactory("LogicV2");
        logicV2 = await LogicV2.deploy();
        await logicV2.waitForDeployment();

        // 升级代理
        const proxyAsProxy = await ethers.getContractAt("TransparentProxy", await proxy.getAddress());
        await proxyAsProxy.upgradeTo(await logicV2.getAddress());

        // 测试新功能
        const proxyAsLogicV2 = await ethers.getContractAt("LogicV2", await proxy.getAddress());
        expect(await proxyAsLogicV2.getValue()).to.equal(43);
        console.log("should upgrade to V2 correctly", await proxyAsLogicV2.getValue());
        await proxyAsLogicV2.decrement();
        expect(await proxyAsLogicV2.getValue()).to.equal(42);
        console.log("should upgrade to V2 correctly", await proxyAsLogicV2.getValue());
        await proxyAsLogicV2.double();
        expect(await proxyAsLogicV2.getValue()).to.equal(84);
        console.log("should upgrade to V2 correctly", await proxyAsLogicV2.getValue());
    });

    it("should maintain storage after upgrade", async function () {
        const proxyAsLogicV2 = await ethers.getContractAt("LogicV2", await proxy.getAddress());
        expect(await proxyAsLogicV2.getValue()).to.equal(84);
        console.log("should maintain storage after upgrade", await proxyAsLogicV2.getValue());
    });
});
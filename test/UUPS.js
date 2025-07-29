const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("UUPS Upgradeable Contract", function () {
    let proxy;
    let owner;
    let user;
    let proxyv2;

    before(async function () {
        [owner, user] = await ethers.getSigners();
    });

    it("should deploy V1", async function () {
        const MyUUPSContractV1 = await ethers.getContractFactory("MyUUPSContractV1");

        proxy = await upgrades.deployProxy(MyUUPSContractV1, [42], {
            initializer: "initialize",
            kind: "uups",
        });

        await proxy.waitForDeployment();
        console.log("Proxy deployed to:", await proxy.getAddress());
        console.log("Address from proxy:", await proxy.getValue());

        expect(await proxy.getValue()).to.equal(42);
    });

    it("should allow increment", async function () {
        await proxy.increment();
        expect(await proxy.getValue()).to.equal(43);
        console.log("Address from proxy:", await proxy.getValue());
    });

    it("should not allow non-owner to upgrade", async function () {
        const MyUUPSContractV2 = await ethers.getContractFactory("MyUUPSContractV2");

        await expect(
            upgrades.upgradeProxy(await proxy.getAddress(), MyUUPSContractV2, {
                call: { from: user.address }
            })
        ).to.be.reverted;
    });

    describe("After upgrade to V2", function () {
        before(async function () {
            const MyUUPSContractV2 = await ethers.getContractFactory("MyUUPSContractV2");
            await upgrades.upgradeProxy(await proxy.getAddress(), MyUUPSContractV2);
            proxyv2 = await ethers.getContractAt("MyUUPSContractV2", await proxy.getAddress());
        });
        it("should maintain state", async function () {
            expect(await proxyv2.getValue()).to.equal(43);
            console.log("Address from proxy:", await proxyv2.getValue());
        });

        it("should have new functions", async function () {
            await proxyv2.decrement();
            expect(await proxyv2.getValue()).to.equal(42);
            console.log("Address from proxy:", await proxyv2.getValue());

            await proxyv2.double();
            expect(await proxyv2.getValue()).to.equal(84);
            console.log("Address from proxy:", await proxyv2.getValue());
        });
    });
});
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import { LRTConfigTest, ILRTConfig, LRTConstants, UtilLib } from "./LRTConfigTest.t.sol";
import { ChainlinkPriceOracle } from "../contracts/oracles/ChainlinkPriceOracle.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MockPriceAggregator {
    function latestAnswer() external pure returns (uint256) {
        return (1 ether + 5);
    }
}

contract ChainlinkPriceOracleTest is LRTConfigTest {
    ChainlinkPriceOracle public priceOracle;

    event UpdatedLRTConfig(address indexed lrtConfig);
    event AssetPriceFeedUpdate(address indexed asset, address indexed priceFeed);

    function setUp() public virtual override {
        super.setUp();

        // initialize LRTConfig
        lrtConfig.initialize(admin, address(stETH), address(rETH), address(cbETH), rsethMock);
        // add manager role
        vm.prank(admin);
        lrtConfig.grantRole(LRTConstants.MANAGER, manager);

        ProxyAdmin proxyAdmin = new ProxyAdmin();
        ChainlinkPriceOracle priceOracleImpl = new ChainlinkPriceOracle();
        TransparentUpgradeableProxy priceOracleProxy = new TransparentUpgradeableProxy(
            address(priceOracleImpl),
            address(proxyAdmin),
            ""
        );

        priceOracle = ChainlinkPriceOracle(address(priceOracleProxy));
    }
}

contract ChainlinkPriceOracleInitialize is ChainlinkPriceOracleTest {
    function test_RevertInitializeIfAlreadyInitialized() external {
        priceOracle.initialize(address(lrtConfig));

        vm.startPrank(admin);
        // cannot initialize again
        vm.expectRevert("Initializable: contract is already initialized");
        priceOracle.initialize(address(lrtConfig));
        vm.stopPrank();
    }

    function test_RevertInitializeIfLRTConfigIsZero() external {
        vm.startPrank(admin);
        vm.expectRevert(UtilLib.ZeroAddressNotAllowed.selector);
        priceOracle.initialize(address(0));
        vm.stopPrank();
    }

    function test_SetInitializableValues() external {
        expectEmit();
        emit UpdatedLRTConfig(address(lrtConfig));
        priceOracle.initialize(address(lrtConfig));

        assertEq(address(priceOracle.lrtConfig()), address(lrtConfig));
    }
}

contract ChainlinkPriceOracleSetPriceFeed is ChainlinkPriceOracleTest {
    MockPriceAggregator public priceFeed;

    function setUp() public override {
        super.setUp();
        priceOracle.initialize(address(lrtConfig));

        priceFeed = new MockPriceAggregator();
    }

    function test_RevertWhenCallerIsNotLRTManager() external {
        vm.startPrank(alice);
        vm.expectRevert(ILRTConfig.CallerNotLRTConfigManager.selector);
        priceOracle.updatePriceFeedFor(address(rETH), address(priceFeed));
        vm.stopPrank();
    }

    function test_RevertWhenAssetIsNotSupported() external {
        address randomAddress = address(0x123);
        vm.startPrank(manager);
        vm.expectRevert(ILRTConfig.AssetNotSupported.selector);
        priceOracle.updatePriceFeedFor(randomAddress, address(priceFeed));
        vm.stopPrank();
    }

    function test_RevertWhenPriceFeedIsZero() external {
        vm.startPrank(manager);
        vm.expectRevert(UtilLib.ZeroAddressNotAllowed.selector);
        priceOracle.updatePriceFeedFor(address(rETH), address(0));
        vm.stopPrank();
    }

    function test_SetAssetPriceFeed() external {
        assertEq(priceOracle.assetPriceFeed(address(rETH)), address(0));

        vm.startPrank(manager);
        expectEmit();
        emit AssetPriceFeedUpdate(address(rETH), address(priceFeed));
        priceOracle.updatePriceFeedFor(address(rETH), address(priceFeed));
        vm.stopPrank();

        assertEq(priceOracle.assetPriceFeed(address(rETH)), address(priceFeed));
    }
}

contract ChainlinkPriceOracleFetchAssetPrice is ChainlinkPriceOracleTest {
    MockPriceAggregator public priceFeed;

    function setUp() public override {
        super.setUp();
        priceOracle.initialize(address(lrtConfig));
        priceFeed = new MockPriceAggregator();

        vm.prank(manager);
        priceOracle.updatePriceFeedFor(address(rETH), address(priceFeed));
    }

    function test_RevertWhenAssetIsNotSupported() external {
        address randomAddress = address(0x123);
        vm.expectRevert(ILRTConfig.AssetNotSupported.selector);
        priceOracle.getAssetPrice(randomAddress);
    }

    function test_FetchAssetPrice() external {
        uint256 rETHPrice = priceOracle.getAssetPrice(address(rETH));
        assertEq(rETHPrice, 1 ether + 5);
    }
}
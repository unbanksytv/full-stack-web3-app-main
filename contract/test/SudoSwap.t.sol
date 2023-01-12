// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "sudoswap/bonding-curves/CurveErrorCodes.sol";
import "sudoswap/bonding-curves/ICurve.sol";
import "sudoswap/LSSVMPairFactory.sol";
import "sudoswap/LSSVMPairETH.sol";
import "sudoswap/LSSVMRouter.sol";
import "sudoswap/LSSVMPairEnumerableETH.sol";
import "sudoswap/LSSVMPair.sol";

import "../src/types/SSMintableNFT.sol";
import "../src/SudoswapMintWrapper.sol";
import "./utils/Utils.sol";
import "./Base.t.sol";

contract SudoswapMintWrapperTest is BaseTest {
    SudoswapMintWrapper wrapper;
    SSMintableNFT nft;

    // mainnet
    address EXPONENTIAL_CURVE = 0x432f962D8209781da23fB37b6B59ee15dE7d9841;
    address PAIR_FACTORY = 0xb16c1342E617A5B6E4b631EB114483FDB289c0A4;
    address PAIR_ROUTER = 0x2B2e8cDA09bBA9660dCA5cB6233787738Ad68329;

    LSSVMPairFactory factory = LSSVMPairFactory(payable(PAIR_FACTORY));
    LSSVMRouter router = LSSVMRouter(payable(PAIR_ROUTER));

    function setUp() public override {
        super.setUp();

        vm.startPrank(deployer);

        nft = new SSMintableNFT(owner, dev);
        wrapper = new SudoswapMintWrapper(address(nft), nft.MAX_SUPPLY() - 100);

        nft.setSudoswapMintWrapperContract(address(wrapper));

        vm.stopPrank();
    }

    function testCreatePool_mainnetFork() public {
        hoax(dev, 100 ether);
        (bool success, ) = deployer.call{value: 10 ether}("");
        if (!success) revert();

        vm.startPrank(deployer);

        uint128 spotPrice = 0.001 ether;
        uint128 delta = 1 ether + 0.001 ether;
        uint256 numItems = 5;
        uint256 feeMultiplier = 0;
        
        uint256[] memory initialNFTs_ = new uint256[](0);
        LSSVMPairETH pool_ = factory.createPairETH(
            IERC721(address(wrapper)),
            ICurve(EXPONENTIAL_CURVE),
            payable(deployer), 
            LSSVMPair.PoolType.NFT,
            delta,
            0,
            spotPrice,
            initialNFTs_
        );
    }

    function testFull_mainnetFork() public {
        hoax(dev, 100 ether);
        (bool success, ) = deployer.call{value: 10 ether}("");
        if (!success) revert();

        vm.startPrank(deployer);
        uint128 spotPrice = 0.001 ether;
        uint128 delta = 1 ether + 0.001 ether;
        uint256 numItems = 5;
        uint256 feeMultiplier = 0;

        uint256[] memory initialNFTs_ = new uint256[](0);
        LSSVMPairETH pool_ = factory.createPairETH(
            IERC721(address(wrapper)),
            ICurve(EXPONENTIAL_CURVE),
            payable(deployer), 
            LSSVMPair.PoolType.NFT,
            delta,
            0,
            spotPrice,
            initialNFTs_
        );

        wrapper.connectWrapperToPool(address(pool_));

        (
            CurveErrorCodes.Error error,
            ,
            ,
            uint256 inputValue,
        ) = pool_.getBuyNFTQuote(numItems);

        require(error == CurveErrorCodes.Error.OK, "Bonding curve error");

        LSSVMRouter.RobustPairSwapAny[] memory tmp_ = new LSSVMRouter.RobustPairSwapAny[](1);
        tmp_[0].swapInfo.pair = LSSVMPair(payable(pool_));
        tmp_[0].swapInfo.numItems = numItems;
        tmp_[0].maxCost = 5 ether;

        uint256 refundedBalance = router.robustSwapETHForAnyNFTs{value: inputValue * 2}(
            tmp_,
            payable(deployer),
            alice,
            1000000000000000000000
        );

        emit log_address(nft.ownerOf(0));
        emit log_uint(nft.balanceOf(alice));
    }
}

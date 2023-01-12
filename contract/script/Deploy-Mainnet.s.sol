// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "sudoswap/bonding-curves/ICurve.sol";
import "sudoswap/LSSVMPairFactory.sol";
import "sudoswap/LSSVMPairETH.sol";
import "sudoswap/LSSVMPair.sol";

import "../src/types/SSMintableNFT.sol";
import "../src/types/Forwarder.sol";
import "../src/SudoswapMintWrapper.sol";

contract ContractScript is Script {
    SudoswapMintWrapper wrapper;
    SSMintableNFT nft;
    Forwarder forwarder;

    address MAINNET_EXPONENTIAL_CURVE = 0x432f962D8209781da23fB37b6B59ee15dE7d9841;
    address MAINNET_PAIR_FACTORY = 0xb16c1342E617A5B6E4b631EB114483FDB289c0A4;

    LSSVMPairFactory factory_mainnet = LSSVMPairFactory(payable(MAINNET_PAIR_FACTORY));

    address dev = 0x3fb4BC89FDD74A1717A1f5ae1b2923022d635C98;

    function run() public {
        vm.startBroadcast();
        nft = new SSMintableNFT(dev, dev);
        wrapper = new SudoswapMintWrapper(address(nft), 6300);

        nft.setSudoswapMintWrapperContract(address(wrapper));

        // Initialize Forward, but change ADDR2 later to point to pair trade pool
        forwarder = new Forwarder(dev, dev);

        uint128 spotPrice = 0.01 ether;
        uint128 delta = 1 ether + 0.00_015 ether;
        
        uint256[] memory initialNFTs_ = new uint256[](0);
        LSSVMPairETH pool_ = factory_mainnet.createPairETH(
            IERC721(address(wrapper)),
            ICurve(MAINNET_EXPONENTIAL_CURVE),
            payable(forwarder), 
            LSSVMPair.PoolType.NFT,
            delta,
            0,
            spotPrice,
            initialNFTs_
        );

        // Initialize bulk transfer & so on
        wrapper.connectWrapperToPool(address(pool_));   

        wrapper.setBaseURI("ipfs://QmeQaVxttbhCGqeexqhnbhbQ5uYtB12Le4ZYuQDSjiVCMU"); 
    }
}

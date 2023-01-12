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

    address RINKEBY_EXPONENTIAL_CURVE = 0xBc6760B11e433D25aAf5c8fCBC6cE99b14aC5D52;
    address RINKEBY_PAIR_FACTORY = 0xcB1514FE29db064fa595628E0BFFD10cdf998F33;
    LSSVMPairFactory factory_rinkeby = LSSVMPairFactory(payable(RINKEBY_PAIR_FACTORY));

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
        LSSVMPairETH pool_ = factory_rinkeby.createPairETH(
            IERC721(address(wrapper)),
            ICurve(RINKEBY_EXPONENTIAL_CURVE),
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

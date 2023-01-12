// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "sudoswap/bonding-curves/CurveErrorCodes.sol";
import "sudoswap/LSSVMPairETH.sol";
import "sudoswap/LSSVMRouter.sol";

import "../src/types/SSMintableNFT.sol";
import "../src/SudoswapMintWrapper.sol";

contract PurchaseScript is Script {
    SSMintableNFT nft = SSMintableNFT(payable(0x8B8cC9233c7Bc4ab54bdaE2e9a9c30d08fE07bBE));
    SudoswapMintWrapper wrapper = SudoswapMintWrapper(payable(0x7e90E60b5200A1E011ddA6AFeD651f31bfb7a085));
    
    LSSVMPairETH pool_ = LSSVMPairETH(payable(0xC090706Aad5d65597449D6cD067E36aE4c4883ED));
    
    address RINKEBY_PAIR_ROUTER = 0x9ABDe410D7BA62fA11EF37984c0Faf2782FE39B5;
    LSSVMRouter router_rinkeby = LSSVMRouter(payable(RINKEBY_PAIR_ROUTER));

    function run() public {
        uint256 numItems = 5;
        
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
        tmp_[0].maxCost = inputValue;

        vm.broadcast();
        address dev = address(this);
        router_rinkeby.robustSwapETHForAnyNFTs{value: inputValue}(
            tmp_,
            payable(dev),
            dev,
            1000000000000000000000
        ); 
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/types/SSMintableNFT.sol";
import "../src/SudoswapMintWrapper.sol";
import "./utils/Utils.sol";
import "./Base.t.sol";

contract SudoswapMintWrapperTest is BaseTest {
    SudoswapMintWrapper wrapper;
    SSMintableNFT nft;

    function setUp() public override {
        super.setUp();

        vm.startPrank(deployer);

        nft = new SSMintableNFT(owner, dev);
        wrapper = new SudoswapMintWrapper(address(nft), nft.MAX_SUPPLY() - 100);

        nft.setSudoswapMintWrapperContract(address(wrapper));

        vm.stopPrank();
    }

    function testMintTrigger() public {
        vm.prank(deployer);
        wrapper.setApprovalForAll(alice, true);

        vm.startPrank(alice);
        wrapper.transferFrom(deployer, alice, 0);
        assertEq(nft.ownerOf(0), alice);

        wrapper.transferFrom(deployer, chris, 1);
        assertEq(nft.ownerOf(1), chris);
    }
}

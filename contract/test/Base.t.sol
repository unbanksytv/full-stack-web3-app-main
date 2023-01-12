// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./utils/Utils.sol";

contract BaseTest is Test {
    Utils internal utils;

    address internal deployer;
    address internal owner;
    address internal dev;

    address internal alice;
    address internal bob;
    address internal chris;

    function setUp() public virtual {
        utils = new Utils();

        deployer = utils.initializeAccount("deployer");
        owner = utils.initializeAccount("owner");
        dev = utils.initializeAccount("dev");

        alice = utils.initializeAccount("alice");
        bob   = utils.initializeAccount("bob");
        chris = utils.initializeAccount("chris");
    }
}

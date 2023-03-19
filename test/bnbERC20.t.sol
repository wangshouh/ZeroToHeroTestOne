// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/bnbERC20.sol";

contract tokenTest is Test {
    BnBCoin private token;

    function setUp() public {
        token = new BnBCoin("BnBCoin", "BCT", 18);
    }

    function test_Init() public {
        assertEq(token.balanceOf(address(this)), 1_000 ether);
    }

    function test_Transfer() public {
        address receiver = address(1);
        token.transfer(receiver, 1000);
        assertEq(token.balanceOf(receiver), 1000);
    }
}
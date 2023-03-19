// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/bnbERC20.sol";
import "../src/stack.sol";

contract stackTest is Test {

	BnBCoin private stakingToken;
	BnBCoin private rewardsToken;
	StakingRewards private stakeContract;

    function setUp() public {
        stakingToken = new BnBCoin("sToken", "sT", 18);
        rewardsToken = new BnBCoin("rToken", "rT", 18);
        stakeContract = new StakingRewards(address(rewardsToken), address(stakingToken));

        rewardsToken.transfer(address(stakeContract), 1_000 ether);
        stakingToken.approve(address(stakeContract), 1_000 ether);
    }

    function test_stake() public {
    	stakeContract.stake(10 ether);

    	assertEq(stakeContract.balanceOf(address(this)), 10 ether);
    	assertEq(stakingToken.balanceOf(address(this)), 990 ether);
    }

    function test_SingleStake() public {
    	stakeContract.stake(10 ether);

    	vm.warp(1 hours + 1);

    	assertEq(stakeContract.earned(address(this)), 0.05 ether);
    }

    function test_SingleAll() public {
        stakeContract.stake(10 ether);

        vm.warp(1 hours + 1);

        stakeContract.withdraw(10 ether);
        assertEq(stakingToken.balanceOf(address(this)), 1000 ether);

        stakeContract.getReward();
        assertEq(rewardsToken.balanceOf(address(this)), 0.05 ether);
    }

    function test_MultiAll() public {
        address testA = address(1);
        address testB = address(2);

        stakingToken.transfer(testA, 10 ether);
        stakingToken.transfer(testB, 10 ether);

        vm.startPrank(testA);
        stakingToken.approve(address(stakeContract), 1_000 ether);
        stakeContract.stake(10 ether);
        vm.stopPrank();

        vm.warp(1 hours + 1);

        vm.startPrank(testB);
        stakingToken.approve(address(stakeContract), 1_000 ether);
        stakeContract.stake(10 ether);
        vm.stopPrank();

        vm.warp(2 hours + 1);

        vm.prank(testB);
        stakeContract.withdraw(10 ether);

        assertEq(stakeContract.undrawnFundsOf(testB), 0.025 ether);

        vm.warp(3 hours + 1);

        vm.prank(testA);
        stakeContract.withdraw(10 ether);

        assertEq(stakeContract.undrawnFundsOf(testA), 0.125 ether);
    }
}
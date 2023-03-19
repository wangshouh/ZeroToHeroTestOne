// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../src/bnbERC20.sol";
import "../src/stack.sol";

contract StackScript is Script {
    function run() external {
        vm.startBroadcast();

        BnBCoin stakingToken = new BnBCoin("sToken", "sT", 18);
        BnBCoin rewardsToken = new BnBCoin("rToken", "rT", 18);
        StakingRewards stakeContract = new StakingRewards(address(rewardsToken), address(stakingToken));

        rewardsToken.transfer(address(stakeContract), 1_000 ether);
        stakingToken.approve(address(stakeContract), 1_000 ether);

        vm.stopBroadcast();
    }
}

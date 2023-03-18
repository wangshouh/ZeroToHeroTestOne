// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../src/bnbERC20.sol";

contract TokenScript is Script {
    function run() external {
        vm.startBroadcast();

        BnBCoin token = new BnBCoin("BnBCoin", "BCT", 18);

        vm.stopBroadcast();
    }
}

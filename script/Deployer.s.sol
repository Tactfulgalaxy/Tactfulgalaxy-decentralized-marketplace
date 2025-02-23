// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {DecentralizedMarketPlace} from "../src/DecentralizedMarketPlace.sol";

contract MyScript is Script {
    function run() external {
        
        vm.startBroadcast();

        new DecentralizedMarketPlace();

        vm.stopBroadcast();
    }
}

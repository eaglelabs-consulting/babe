// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuaveCaller} from "../src/SuaveCaller.sol";

contract DeploySuaveCaller is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK_WITHPREFIX");
        vm.startBroadcast(deployerPrivateKey);

        SuaveCaller suaveCaller = new SuaveCaller();

        console.log("Deployed SuaveCaller at:", address(suaveCaller));
        vm.stopBroadcast();
    }
}

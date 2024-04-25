// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SuaveCaller} from "../src/SuaveCaller.sol";

contract ExecuteSuaveCaller is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("WALLET_PK");
        vm.startBroadcast(deployerPrivateKey);

        SuaveCaller suaveCaller = SuaveCaller(vm.envAddress("SUAVE_CALLER_ADDR"));
        console.log("Calling babe through:", address(suaveCaller));

        uint256 subnetId = vm.envUint("SUBNET_ID");

        if (subnetId == 0) {
            _useChatGptSubnet(suaveCaller);
        }

        vm.stopBroadcast();
    }

    function _useChatGptSubnet(SuaveCaller _suaveCaller) internal {
        uint256 role = vm.envUint("CHATGPT_MESSAGE_ROLE");
        string memory content = vm.envString("CHATGPT_MESSAGE_CONTENT");

        console.log("role:", role);
        console.log("content:", content);

        bytes memory subnetData = abi.encode(role, content);
        console.log("subnet data:");
        console.logBytes(subnetData);

        _suaveCaller.callBabe(0, subnetData);
    }
}

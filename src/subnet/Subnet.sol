// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// interfaces
import {ISubnet} from "./interface/ISubnet.sol";
// contracts
import {Suapp} from "suave-std/Suapp.sol";

contract Subnet is Suapp, ISubnet {
    function execute(bytes calldata _subnetData) external virtual returns (bytes memory) {
        return abi.encodeWithSelector(Subnet.execute.selector, _subnetData);
    }
}

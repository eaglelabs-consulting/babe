// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// interfaces
import {ISubnet} from "./interface/ISubnet.sol";

contract SubnetRegistry {
    mapping(uint256 => ISubnet) internal subnetAddr_;

    // to remove
    address private chatgptsubnet = 0xbe81147417cc8f3bff4738897b2F9b3fF90A63b7;

    constructor() {
        subnetAddr_[0] = ISubnet(chatgptsubnet);
    }

    function setSubnetAddr(uint256 _id, address _addr) external {
        subnetAddr_[_id] = ISubnet(_addr);
    }

    function getSubnetById(uint256 _id) external view returns (ISubnet) {
        return subnetAddr_[_id];
    }
}

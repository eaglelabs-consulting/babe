// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// interfaces
import {ISubnet} from "./interface/ISubnet.sol";
// contracts
import {Ownable} from "solady-pkg/auth/Ownable.sol";

contract SubnetRegistry is Ownable {
    mapping(uint256 => ISubnet) internal subnetAddr_;

    // to remove
    address private chatgptsubnet = 0xcb632cC0F166712f09107a7587485f980e524fF6;

    constructor() {
        subnetAddr_[0] = ISubnet(chatgptsubnet);
    }

    function setSubnetAddr(uint256 _id, address _addr) external onlyOwner() {
        subnetAddr_[_id] = ISubnet(_addr);
    }

    function getSubnetById(uint256 _id) external view returns (ISubnet) {
        return subnetAddr_[_id];
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// interfaces
import {ISubnet} from "./interface/ISubnet.sol";

contract SubnetRegistry {
    mapping(uint256 => ISubnet) internal subnetAddr_;

    function setSubnetAddr(uint256 _id, address _addr) external {
        subnetAddr_[_id] = ISubnet(_addr);
    }

    function getSubnetById(uint256 _id) external view returns (ISubnet) {
        return subnetAddr_[_id];
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// interfaces
import {ISubnet} from "./interface/ISubnet.sol";

contract SubnetRegistry {
    mapping(uint256 => ISubnet) internal subnetAddr_;

    // to remove
    address private chatgptsubnet = 0x43799f8287Fd7e46a47AE4ac46bFD0de23Dc038C;

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

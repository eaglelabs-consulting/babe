// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ISubnet {
    function execute(bytes calldata _subnetData) external returns (bytes memory);
}

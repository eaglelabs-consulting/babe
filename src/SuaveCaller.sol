// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SuaveCaller {
    event Baaabe(uint256 indexed subnetId, bytes subnetData);

    // _subnetId 0 for ChatGPT
    function callBabe(uint256 _subnetId, bytes calldata _subnetData) external {
        emit Baaabe(_subnetId, _subnetData);
    }
}

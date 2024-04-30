// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SuaveCaller {
    error InvalidBabeOutput();
    error AlreadyDone();

    mapping(uint256 => mapping(bytes => bytes)) public babeResults;

    event Baaabe(uint256 indexed subnetId, bytes subnetData);

    // _subnetId 0 for ChatGPT
    function callBabe(uint256 _subnetId, bytes calldata _subnetData) external {
        emit Baaabe(_subnetId, _subnetData);
    }

    function babeCallback(uint256[] calldata _subnetId, bytes[] calldata _subnetData, bytes[] calldata _results)
        external
    {
        if (_subnetId.length != _subnetData.length || _subnetData.length != _results.length) {
            revert InvalidBabeOutput();
        }

        for (uint256 i; i < _subnetId.length; i++) {
            babeResults[_subnetId[i]][_subnetData[i]] = _results[i];
        }
    }
}

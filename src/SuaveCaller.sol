// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SuaveCaller {
    event Baaabe(bytes indexed job);

    function callBabe(bytes calldata _job) external {
        emit Baaabe(_job);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Suapp} from "suave-std/Suapp.sol";
import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";

contract Babe is Suapp, ChatGPT {
    string private basescanApiKey;

    uint256 public lastBlock; // Last block number that was processed

    event JobProcessed(bytes indexed job, bytes result);
    event TransactionSent(bytes indexed txn);

    constructor(string memory _chatGptKey, string memory _basescanApiKey) ChatGPT(_chatGptKey) {
        basescanApiKey = _basescanApiKey;
    }

    function monitorBabeCalls() external {
        
    }
}
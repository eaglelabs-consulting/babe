// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// contracts
import {Suapp} from "suave-std/Suapp.sol";
import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";
import {BaseEventFetcher} from "./BaseEventFetcher.sol";

contract Babe is Suapp, ChatGPT, BaseEventFetcher {
    string constant private _chatGptKey = "";
    string constant private _basescanApiKey = "EKSH4E6V9GG3KZVINDJRE66RRDN56YHW4V";

    address constant private _suaveCallerOnBase = 0xBaeaB45EF6408e4e2E54bb6CA8516C4F9E6972F5;

    // string public lastMonitoredBlock = "0";
    string public lastMonitoredBlock = "8799322";

    event JobProcessed(bytes indexed job, bytes result);
    // event TransactionSent(bytes indexed txn);
    event TransactionSent(string b);
    event Job(string b);
    event Size(uint256 s);

    constructor() ChatGPT(_chatGptKey) BaseEventFetcher(_basescanApiKey) {
    }

    function monitorBabeCalls() external returns (bytes memory) {
        string memory baseBlockNumber = _getBaseBlockNumber();
        string[] memory events;
        uint256 chSize;

        if (keccak256(abi.encodePacked(lastMonitoredBlock)) == keccak256(abi.encodePacked("0"))) {
            (events, chSize) = _getBaseEvents(_suaveCallerOnBase, baseBlockNumber);
        } else {
            (events, chSize) = _getBaseEvents(_suaveCallerOnBase, lastMonitoredBlock);
        }

        return abi.encodeWithSelector(this.postJobResult.selector, baseBlockNumber, events, chSize);
    }

    function postJobResult(string calldata _b, string[] calldata _events, uint256 _chSize) external {
        lastMonitoredBlock = _b;

        emit TransactionSent(_b);
        emit Size(_chSize);

        for(uint256 i; i < _chSize; i++) {
            emit Job(_events[i]);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Suave} from "suave-std/suavelib/Suave.sol";

contract BaseEventFetcher {
    string public constant URL = "https://api-sepolia.basescan.org/api";

    function _getBaseEvents(uint256 _fromBlock) internal {
        // empty body
        bytes memory body;

        // ?module=logs
        // &action=getLogs
        // &fromBlock=0
        // &toBlock=latest
        // &address=0x61284008eccba03ebf84f5888c90dfaa23a00ae7
        // &topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
        // &apikey=YourApiKeyToken
        string memory module = "logs";
        string memory action = "getLogs";
        string memory fromBlock = "getLogs";

        string[] memory headers = new string[](1);
        headers[0] = string.concat("Authorization: Bearer ", "asa", "ass");


        Suave.HttpRequest memory request;
        request.method = "PUT";
        request.body = body;
        request.headers = headers;
        request.withFlashbotsSignature = false;
   
    }
}
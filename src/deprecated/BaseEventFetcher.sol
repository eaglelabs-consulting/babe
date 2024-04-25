// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// // libs
// import {LibString} from "solady-pkg/utils/LibString.sol";
// import {JSONParserLib} from "solady-pkg//utils/JSONParserLib.sol";
// // contracts
// import {Suave} from "suave-std/suavelib/Suave.sol";

// import {console} from "forge-std/console.sol";

// contract BaseEventFetcher {
//     using JSONParserLib for *;

//     string public constant URL = "https://api-sepolia.basescan.org/api";

//     string private basescanApiKey;

//     event BaseBlockNumber(string b);

//     constructor(string memory _basescanApiKey) {
//         basescanApiKey = _basescanApiKey;
//     }

//     function _getBaseBlockNumber() internal returns (string memory) {
//         // get blocknumber from base chain

//         // ?module=block
//         // &action=getblocknobytime
//         // &timestamp=1702447596
//         // &closest=before
//         // &apikey=YourApiKeyToken
//         // empty body

//         string memory moduleParam = "block";
//         string memory actionParam = "getblocknobytime";
//         string memory timestampParam = LibString.toString(block.timestamp);
//         string memory closestParam = "before";

//         Suave.HttpRequest memory baseBlockNumberRequest;
//         baseBlockNumberRequest.url = string.concat(
//             URL,
//             "?module=",
//             moduleParam,
//             "&action=",
//             actionParam,
//             "&timestamp=",
//             timestampParam,
//             "&closest=",
//             closestParam,
//             "&apikey=",
//             basescanApiKey
//         );
//         baseBlockNumberRequest.method = "GET";
//         baseBlockNumberRequest.withFlashbotsSignature = false;

//         bytes memory output = Suave.doHTTPRequest(baseBlockNumberRequest);

//         // decode responses
//         JSONParserLib.Item memory item = string(output).parse();
//         return _trimQuotes(item.at('"result"').value());
//     }

//     function _getBaseEvents(address _suaveCaller, string memory _fromBlock)
//         internal
//         returns (string[] memory, uint256)
//     {
//         // get events

//         // ?module=logs
//         // &action=getLogs
//         // &fromBlock=_fromBlock
//         // &toBlock=latest
//         // &address=0xBaeaB45EF6408e4e2E54bb6CA8516C4F9E6972F5
//         // &apikey=YourApiKeyToken
//         string memory moduleParam = "logs";
//         string memory actionParam = "getLogs";
//         string memory toBlockParam = "latest";
//         string memory addressParam = LibString.toHexStringChecksummed(_suaveCaller);

//         Suave.HttpRequest memory eventsRequest;
//         eventsRequest.method = "GET";
//         eventsRequest.url = string.concat(
//             URL,
//             "?module=",
//             moduleParam,
//             "&action=",
//             actionParam,
//             "&fromBlock=",
//             _fromBlock,
//             "&toBlock=",
//             toBlockParam,
//             "&address=",
//             addressParam,
//             "&apikey=",
//             basescanApiKey
//         );
//         eventsRequest.withFlashbotsSignature = false;

//         bytes memory output = Suave.doHTTPRequest(eventsRequest);

//         // decode responses
//         JSONParserLib.Item memory item = string(output).parse();
//         uint256 jobsCounter = item.at('"result"').size();
//         string[] memory jobs = new string[](jobsCounter);

//         for (uint256 i; i < jobsCounter; i++) {
//             jobs[i] = _trimQuotes(item.at('"result"').at(i).at('"topics"').at(1).value());
//         }

//         return (jobs, jobsCounter);
//         // return (item.at('"result"').at(0).at('"topics"').at(1).value(), jobsCounter);
//     }

//     function _trimQuotes(string memory input) private pure returns (string memory) {
//         bytes memory inputBytes = bytes(input);
//         require(
//             inputBytes.length >= 2 && inputBytes[0] == '"' && inputBytes[inputBytes.length - 1] == '"', "Invalid input"
//         );

//         bytes memory result = new bytes(inputBytes.length - 2);

//         for (uint256 i = 1; i < inputBytes.length - 1; i++) {
//             result[i - 1] = inputBytes[i];
//         }

//         return string(result);
//     }
// }

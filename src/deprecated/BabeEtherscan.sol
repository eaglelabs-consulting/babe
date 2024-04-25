// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// // contracts
// import {Suapp} from "suave-std/Suapp.sol";
// import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";
// import {BaseEventFetcher} from "./BaseEventFetcher.sol";
// import {HexStrings} from "suave-std/utils/HexStrings.sol";

// contract Babe is Suapp, BaseEventFetcher {
//     string private constant _chatGptKey = "sk-proj-7AhfAzbw0x6DIgpPkiyUT3BlbkFJBzxZjrIz1YVd1a3Oojfs";
//     string private constant _basescanApiKey = "EKSH4E6V9GG3KZVINDJRE66RRDN56YHW4V";

//     address private constant _suaveCallerOnBase = 0x58dbAa53becEC0bC11A3258132EB6e83EafE0493;

//     // string public lastMonitoredBlock = "0";
//     string public lastMonitoredBlock = "8850703";

//     event JobProcessed(bytes indexed job, bytes result);

//     event ChatgptPrompt(string content);

//     event JobInString(string s);
//     event JobInByte(bytes b);

//     constructor() BaseEventFetcher(_chatGptKey) {}

//     function monitorBabeCalls() external returns (bytes memory) {
//         string memory baseBlockNumber = _getBaseBlockNumber();
//         string[] memory events;
//         uint256 chSize;

//         if (keccak256(abi.encodePacked(lastMonitoredBlock)) == keccak256(abi.encodePacked("0"))) {
//             (events, chSize) = _getBaseEvents(_suaveCallerOnBase, baseBlockNumber);
//         } else {
//             (events, chSize) = _getBaseEvents(_suaveCallerOnBase, lastMonitoredBlock);
//         }

//         ChatGPT.Message[] memory messages = new ChatGPT.Message[](1);

//         for (uint256 i; i < chSize; i++) {
//             bytes memory bString = bytes(events[i]);

//             // (uint256 role, string memory content) = abi.decode(bString, (uint256, string));

//             // messages[0].role = role == 0 ? ChatGPT.Role.User : ChatGPT.Role.System;
//             // messages[0].content = content;
//         }

//         return abi.encodeWithSelector(this.postJobResult.selector, baseBlockNumber, events, chSize, messages[0].content);
//     }

//     function postJobResult(
//         string calldata _b,
//         string[] calldata _events,
//         uint256 _chSize,
//         string calldata _chatgptContent
//     ) external {
//         // lastMonitoredBlock = _b;

//         for (uint256 i; i < _chSize; i++) {
//             emit JobInString(_events[i]);

//             // bytes memory enc = HexStrings.fromHexString(_events[i]);

//             // emit JobInByte(enc);

//             // (uint256 role, string memory content) = abi.decode(enc, (uint256, string));

//             // emit ChatgptPrompt(content);
//         }
//     }
// }

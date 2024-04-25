// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// contracts
import {Suapp} from "suave-std/Suapp.sol";
import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";
import {EthJsonRPC, JSONParserLib, HexStrings} from "suave-std/protocols/EthJsonRPC.sol";
import {BaseEventFetcher} from "./BaseEventFetcher.sol";
import {LibString} from "solady-pkg/utils/LibString.sol";

import {SubnetRegistry} from "./SubnetRegistry.sol";

contract Babe is Suapp, EthJsonRPC, SubnetRegistry {
    using JSONParserLib for *;

    string private constant _basescanApiKey = "EKSH4E6V9GG3KZVINDJRE66RRDN56YHW4V";
    string private constant _endpoint = "https://base-sepolia.g.alchemy.com/v2/uLZ1b44XjfcON0eacWHzK3arrhfJjHid";
    address private constant _suaveCallerOnBase = 0x89EAA8f4fcf1a6b986E5B2beDb40b01Ab9Ce395a;

    uint256 public lastMonitoredBlock = 8893087;

    event JobProcessed(bytes indexed job, bytes result);
    event BlockN(uint256 indexed n);
    event SubId(uint256 id);
    event SubData(bytes d);

    constructor() EthJsonRPC(_endpoint) {}

    struct BabeJob {
        uint256 subnetId;
        bytes subnetData;
    }

    function _getBabeJobs() internal returns (BabeJob[] memory) {
        string memory blockInHex = LibString.toMinimalHexString(lastMonitoredBlock);
        string memory body = string.concat("{");
        body = string.concat(body, '"id": "1", ');
        body = string.concat(body, '"method":"eth_getLogs", ');
        body = string.concat(body, '"jsonrpc":"2.0", ');
        body = string.concat(body, '"jsonrpc":"2.0", ');
        body = string.concat(body, '"params": [{');
        body = string.concat(body, '"address": ["', LibString.toHexString(_suaveCallerOnBase), '"], ');
        body = string.concat(body, '"fromBlock": "', blockInHex, '", ');
        body = string.concat(body, '"toBlock": "latest", ');
        body = string.concat(body, '"topics": ["0x9f5a480beecac1261f5330f1e3e282cb6e7ac3821fc2e97ef70fc4e6271cffb4"]');
        body = string.concat(body, "}]");
        body = string.concat(body, "}");

        JSONParserLib.Item memory result = doRequest(body);
        uint256 jobsCounter = result.size();
        BabeJob[] memory jobs = new BabeJob[](jobsCounter);

        for (uint256 i; i < jobsCounter; i++) {
            jobs[i].subnetId = abi.decode(
                HexStrings.fromHexString(_stripQuotesAndPrefix(result.at(i).at('"topics"').at(1).value())), (uint256)
            );
            jobs[i].subnetData =
                abi.decode(HexStrings.fromHexString(_stripQuotesAndPrefix(result.at(i).at('"data"').value())), (bytes));
        }

        return jobs;
    }

    function monitorBabeCalls() external returns (bytes memory) {
        BabeJob[] memory jobs = _getBabeJobs();
        bytes[] memory jobsResults = new bytes[](jobs.length);

        for (uint256 i; i < jobs.length; i++) {
            emit SubId(jobs[i].subnetId);
            emit SubData(jobs[i].subnetData);

            jobsResults[i] = subnetAddr_[jobs[i].subnetId].execute(jobs[i].subnetData);
        }

        return abi.encodeWithSelector(this.postJobResult.selector, _getLatestBlockNumber());
    }

    function postJobResult(uint256 _currentBaseBlockNum) external emitOffchainLogs {
        emit BlockN(_currentBaseBlockNum);
    }

    function _getLatestBlockNumber() private returns (uint256) {
        string memory body = string.concat('{"id": "1", "method":"eth_blockNumber", "jsonrpc":"2.0"}');

        JSONParserLib.Item memory result = doRequest(body);

        return JSONParserLib.parseUintFromHex(_stripQuotesAndPrefix(result.value()));
    }

    function trimQuotess(string memory input) private pure returns (string memory) {
        bytes memory inputBytes = bytes(input);
        require(
            inputBytes.length >= 2 && inputBytes[0] == '"' && inputBytes[inputBytes.length - 1] == '"', "Invalid input"
        );

        bytes memory result = new bytes(inputBytes.length - 2);

        for (uint256 i = 1; i < inputBytes.length - 1; i++) {
            result[i - 1] = inputBytes[i];
        }

        return string(result);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// contracts
import {Subnet} from "./Subnet.sol";
import {Context} from "suave-std/Context.sol";
import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";
import {Suapp} from "suave-std/Suapp.sol";
// libs
import {Suave} from "suave-std/suavelib/Suave.sol";

// import {EthJsonRPC, JSONParserLib, HexStrings} from "suave-std/protocols/EthJsonRPC.sol";
// import {LibString} from "solady-pkg/utils/LibString.sol";

contract ChatGPTSubnet is Suapp, Subnet {
    string internal constant API_KEY_NAMESPACE = "api_key:v0:secret";

    Suave.DataId apiKeyRecord;

    function updateKeyOnchain(Suave.DataId _apiKeyRecord) public {
        apiKeyRecord = _apiKeyRecord;
    }

    function registerKeyOffchain() public returns (bytes memory) {
        bytes memory keyData = Context.confidentialInputs();

        address[] memory peekers = new address[](1);
        peekers[0] = address(this);

        Suave.DataRecord memory record = Suave.newDataRecord(0, peekers, peekers, API_KEY_NAMESPACE);
        Suave.confidentialStore(record.id, API_KEY_NAMESPACE, keyData);

        return abi.encodeWithSelector(this.updateKeyOnchain.selector, record.id);
    }

    function execute(bytes calldata _subnetData) external override returns (bytes memory) {
        bytes memory keyData = Suave.confidentialRetrieve(apiKeyRecord, API_KEY_NAMESPACE);
        string memory apiKey = bytesToString(keyData);
        ChatGPT chatgpt = new ChatGPT(apiKey);

        (uint256 role, string memory con) = abi.decode(_subnetData, (uint256, string));

        ChatGPT.Message[] memory messages = new ChatGPT.Message[](1);
        messages[0] = role == 0 ? ChatGPT.Message(ChatGPT.Role.User, con) : ChatGPT.Message(ChatGPT.Role.System, con);

        string memory data = chatgpt.complete(messages);

        // return abi.encodeWithSelector(this.onchain.selector);

        return abi.encode(data);
    }

    // function onchain() public emitOffchainLogs {}

    function bytesToString(bytes memory data) private pure returns (string memory) {
        uint256 length = data.length;
        bytes memory chars = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            chars[i] = data[i];
        }

        return string(chars);
    }
}

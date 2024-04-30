// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// contracts
import {Subnet} from "./Subnet.sol";
import {Context} from "suave-std/Context.sol";
// import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";
import {Suapp} from "suave-std/Suapp.sol";
// libs
import {Suave} from "suave-std/suavelib/Suave.sol";
import {JSONParserLib} from "solady-pkg/utils/JSONParserLib.sol";

// import {EthJsonRPC, JSONParserLib, HexStrings} from "suave-std/protocols/EthJsonRPC.sol";
// import {LibString} from "solady-pkg/utils/LibString.sol";

contract ChatGPTSubnet is Suapp, Subnet {
    using JSONParserLib for *;

    enum Role {
        User,
        System
    }

    string internal constant API_KEY_NAMESPACE = "api_key:v0:secret";

    Suave.DataId apiKeyRecord;

    struct Message {
        Role role;
        string content;
    }

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
        // string memory data = "";
        bytes memory keyData = Suave.confidentialRetrieve(apiKeyRecord, API_KEY_NAMESPACE);
        string memory apiKey = bytesToString(keyData);
        // ChatGPT chatgpt = new ChatGPT(apiKey);

        (uint256 role, string memory con) = abi.decode(_subnetData, (uint256, string));

        Message[] memory messages = new Message[](1);
        messages[0] = role == 0 ? Message(Role.User, con) : Message(Role.System, con);

        string memory data = complete(apiKey, messages);

        return abi.encode(data);
    }

    function bytesToString(bytes memory data) private pure returns (string memory) {
        uint256 length = data.length;
        bytes memory chars = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            chars[i] = data[i];
        }

        return string(chars);
    }

    /// @notice complete a chat with the OpenAI ChatGPT.
    /// @param messages the messages to complete the chat.
    /// @return message the response from the OpenAI ChatGPT.
    function complete(string memory _apiKey, Message[] memory messages) internal returns (string memory) {
        bytes memory body;
        body = abi.encodePacked('{"model": "gpt-3.5-turbo", "messages": [');
        for (uint256 i = 0; i < messages.length; i++) {
            body = abi.encodePacked(
                body,
                '{"role": "',
                messages[i].role == Role.User ? "user" : "system",
                '", "content": "',
                messages[i].content,
                '"}'
            );
            if (i < messages.length - 1) {
                body = abi.encodePacked(body, ",");
            }
        }
        body = abi.encodePacked(body, '], "temperature": 0.7}');

        Suave.HttpRequest memory request;
        request.method = "POST";
        request.url = "https://api.openai.com/v1/chat/completions";
        request.headers = new string[](2);
        request.headers[0] = string.concat("Authorization: Bearer ", _apiKey);
        request.headers[1] = "Content-Type: application/json";
        request.body = body;

        bytes memory output = Suave.doHTTPRequest(request);

        // decode responses
        JSONParserLib.Item memory item = string(output).parse();
        string memory result = trimQuotes(item.at('"choices"').at(0).at('"message"').at('"content"').value());

        return result;
    }

    function trimQuotes(string memory input) private pure returns (string memory) {
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

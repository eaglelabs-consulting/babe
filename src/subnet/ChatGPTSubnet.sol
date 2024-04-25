// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// contracts
import {Subnet} from "./Subnet.sol";
import {Context} from "suave-std/Context.sol";
import {ChatGPT} from "suave-std/protocols/ChatGPT.sol";
import {Suapp} from "suave-std/Suapp.sol";

// import {EthJsonRPC, JSONParserLib, HexStrings} from "suave-std/protocols/EthJsonRPC.sol";
// import {LibString} from "solady-pkg/utils/LibString.sol";

contract ChatGPTSubnet is Suapp, Subnet {
    Suave.DataId apiKeyRecord;
    string public chatGptKey = "API_KEY";

    event ChatgptPrompt(uint256 role, string content);
    event Response(string messages);

    function updateKeyOnchain(Suave.DataId _apiKeyRecord) public {
        apiKeyRecord = _apiKeyRecord;
    }

    function registerKeyOffchain() public returns (bytes memory) {
        bytes memory keyData = Context.confidentialInputs();

        address[] memory peekers = new address[](1);
        peekers[0] = address(this);

        Suave.DataRecord memory record = Suave.newDataRecord(0, peekers, peekers, "api_key");
        Suave.confidentialStore(record.id, chatGptKey, keyData);

        return abi.encodeWithSelector(this.updateKeyOnchain.selector, record.id);
    }

    function execute(bytes calldata _subnetData) external override returns (bytes memory) {
        bytes memory keyData = Suave.confidentialRetrieve(apiKeyRecord, chatGptKey);
        string memory apiKey = bytesToString(keyData);
        ChatGPT chatgpt = new ChatGPT(apiKey);

        (uint256 role, string memory con) = abi.decode(_subnetData, (uint256, string));

        emit ChatgptPrompt(role, con);

        ChatGPT.Message[] memory messages = new ChatGPT.Message[](1);
        messages[0] = ChatGPT.Message(ChatGPT.Role.User, "Say hello world");

        string memory data = chatgpt.complete(messages);

        emit Response(data);

        return abi.encodeWithSelector(this.onchain.selector);
    }

    function onchain() public emitOffchainLogs {}

    function bytesToString(bytes memory data) private pure returns (string memory) {
        uint256 length = data.length;
        bytes memory chars = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            chars[i] = data[i];
        }

        return string(chars);
    }
}
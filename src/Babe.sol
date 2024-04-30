// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// contracts
import {Suapp} from "suave-std/Suapp.sol";
import {HexStrings} from "suave-std/utils/HexStrings.sol";
import {LibString} from "solady-pkg/utils/LibString.sol";
import {JSONParserLib} from "solady-pkg/utils/JSONParserLib.sol";
import {SubnetRegistry} from "./SubnetRegistry.sol";
// libs
import {Suave} from "suave-std/suavelib/Suave.sol";
import {Context} from "suave-std/Context.sol";
import {Transactions} from "suave-std/Transactions.sol";

contract Babe is Suapp, SubnetRegistry {
    using JSONParserLib for *;

    string internal constant SIGNING_KEY_NAMESPACE = "signing_key:v0:secret";
    string internal constant RPC_NAMESPACE = "rpc:v0:secret";

    address internal constant SIGNING_ADDRESS = 0x52BE7E4ea7374C573bE31e67ebA89C62648c3BEE;

    address private constant _suaveCallerOnBase = 0x336B884a3fDfE45861fF83Ccc0cdae76e967a07a;

    Suave.DataId internal signingKeyRecord;
    mapping(uint256 => Suave.DataId) internal rpcEndpointRecord;

    uint256 public lastMonitoredBlock = 8893087;

    event JobProcessed(bytes indexed job, bytes result);
    event BlockN(uint256 indexed n);
    event SubId(uint256 id);
    event SubData(bytes d);
    event Result(string s);
    event res(string s);
    event SignedTx(bytes tx);

    event kd(bytes kd);
    event kds(string s);

    constructor() {
        _initializeOwner(msg.sender);
    }

    function registerEndpointOffchain(uint256 _chainId) external onlyOwner returns (bytes memory) {
        bytes memory keyData = Context.confidentialInputs();
        address[] memory peekers = new address[](1);
        peekers[0] = address(this);

        Suave.DataRecord memory record = Suave.newDataRecord(0, peekers, peekers, RPC_NAMESPACE);
        Suave.confidentialStore(record.id, RPC_NAMESPACE, keyData);

        return abi.encodeWithSelector(this.updateEndpointOffchain.selector, _chainId, record.id);
    }

    function updateEndpointOffchain(uint256 _chainId, Suave.DataId _rpcEndpointRecord) external {
        rpcEndpointRecord[_chainId] = _rpcEndpointRecord;
    }

    function registerSigningKey() external onlyOwner returns (bytes memory) {
        bytes memory keyData = Context.confidentialInputs();
        address[] memory peekers = new address[](1);
        peekers[0] = address(this);

        Suave.DataRecord memory record = Suave.newDataRecord(0, peekers, peekers, SIGNING_KEY_NAMESPACE);
        Suave.confidentialStore(record.id, SIGNING_KEY_NAMESPACE, keyData);

        return abi.encodeWithSelector(this.updateSigningKey.selector, record.id);
    }

    function updateSigningKey(Suave.DataId _signingKeyRecord) external {
        signingKeyRecord = _signingKeyRecord;
    }

    function monitorBabeCalls(uint256 _chainId, uint256 _gas, uint256 _gasPrice)
        external
        onlyOwner
        returns (bytes memory)
    {
        string memory rpcEndoint = bytesToString(Suave.confidentialRetrieve(rpcEndpointRecord[_chainId], RPC_NAMESPACE));
        emit kds(rpcEndoint);

        uint256[] memory subnetIds;
        bytes[] memory subnetDatas;
        (subnetIds, subnetDatas) = _getBabeJobs(rpcEndoint);

        bytes[] memory jobsResults = new bytes[](subnetIds.length);

        for (uint256 i; i < subnetIds.length; i++) {
            emit SubId(subnetIds[i]);
            emit SubData(subnetDatas[i]);

            // jobsResults[i] = subnetAddr_[subnetIds[i]].execute(subnetDatas[i]);

            (bool ok, bytes memory result) =
                address(subnetAddr_[subnetIds[i]]).staticcall(abi.encodeWithSignature("execute(bytes)", subnetDatas[i]));
            require(ok);

            jobsResults[i] = abi.decode(result, (bytes));
        }

        // uint256 signingKey = uint256(
        //     bytes32(
        //         Suave.confidentialRetrieve(signingKeyRecord, SIGNING_KEY_NAMESPACE)
        //     )
        // );

        // // create tx to sign with private key
        // bytes memory targetCall = abi.encodeWithSignature(
        //     "babeCallback(uint256[],bytes[],bytes[])",
        //     subnetIds,
        //     subnetDatas,
        //     jobsResults
        // );

        // // create transaction
        // Transactions.EIP155Request memory txn = Transactions.EIP155Request({
        //     to: _suaveCallerOnBase,
        //     gas: _gas,
        //     gasPrice: _gasPrice,
        //     value: 0,
        //     nonce: _nonce(rpcEndoint, SIGNING_ADDRESS),
        //     data: targetCall,
        //     chainId: _chainId
        // });

        // // encode transaction
        // bytes memory rlpTxn = Transactions.encodeRLP(txn);

        // // sign transaction with key
        // bytes memory signedTxn = Suave.signEthTransaction(
        //     rlpTxn,
        //     LibString.toMinimalHexString(_chainId),
        //     LibString.toHexStringNoPrefix(signingKey)
        // );

        // string memory id = Suave.newBuilder();

        // Suave.SimulateTransactionResult memory sim1 = Suave.simulateTransaction(id, rlpTxn);
        // require(sim1.success == true);
        // require(sim1.logs.length == 1);

        // // send transaction over http json to stored enpoint
        // Suave.HttpRequest memory httpRequest = encodeEthSendRawTransaction(
        //     signedTxn,
        //     rpcEndoint
        // );
        // bytes memory output = Suave.doHTTPRequest(httpRequest);
        // JSONParserLib.Item memory item = string(output).parse();
        // JSONParserLib.Item memory result = item.at('"result"');

        // emit SignedTx(signedTxn);

        // emit res(result.value());

        // return abi.encodeWithSelector(this.postJobResult.selector, _getLatestBlockNumber(rpcEndoint), jobsResults);

        return abi.encodeWithSelector(this.postJobResult.selector, 0, jobsResults);
    }

    /**
     * @dev Encodes the Ethereum transaction for sending via HTTP request
     * @param signedTxn The signed transaction bytes
     * @param url The URL to send the transaction to
     * @return Suave.HttpRequest Struct containing HTTP request information
     */
    function encodeEthSendRawTransaction(bytes memory signedTxn, string memory url)
        internal
        pure
        returns (Suave.HttpRequest memory)
    {
        bytes memory body = abi.encodePacked(
            '{"jsonrpc":"2.0","method":"eth_sendRawTransaction","params":["',
            LibString.toHexString(signedTxn),
            '"],"id":1}'
        );

        Suave.HttpRequest memory request;
        request.method = "POST";
        request.body = body;
        request.headers = new string[](1);
        request.headers[0] = "Content-Type: application/json";
        request.withFlashbotsSignature = false;
        request.url = url;

        return request;
    }

    function _nonce(string memory _rpcEndpoint, address addr) public returns (uint256) {
        bytes memory body = abi.encodePacked(
            '{"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["',
            LibString.toHexStringChecksummed(addr),
            '","latest"],"id":1}'
        );

        JSONParserLib.Item memory item = _doRequest(_rpcEndpoint, string(body));
        uint256 val = JSONParserLib.parseUintFromHex(_trimQuotes(item.value()));
        return val;
    }

    function bytesToString(bytes memory data) internal pure returns (string memory) {
        uint256 length = data.length;
        bytes memory chars = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            chars[i] = data[i];
        }

        return string(chars);
    }

    function postJobResult(uint256 _currentBaseBlockNum, bytes[] calldata _results) external emitOffchainLogs {
        // for(uint i = 0; i < _results.length; i++) {
        //     emit Result(abi.decode(_results[i], (string)));
        // }

        emit BlockN(_currentBaseBlockNum);
    }

    function _getBabeJobs(string memory _rpcEndpoint) internal returns (uint256[] memory, bytes[] memory) {
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

        JSONParserLib.Item memory result = _doRequest(_rpcEndpoint, body);
        uint256 jobsCounter = result.size();
        uint256[] memory subnetIds = new uint256[](jobsCounter);
        bytes[] memory subnetDatas = new bytes[](jobsCounter);

        for (uint256 i; i < jobsCounter; i++) {
            subnetIds[i] = abi.decode(
                HexStrings.fromHexString(_stripQuotesAndPrefix(result.at(i).at('"topics"').at(1).value())), (uint256)
            );
            subnetDatas[i] =
                abi.decode(HexStrings.fromHexString(_stripQuotesAndPrefix(result.at(i).at('"data"').value())), (bytes));
        }

        return (subnetIds, subnetDatas);
    }

    function _doRequest(string memory _endpoint, string memory body) internal returns (JSONParserLib.Item memory) {
        Suave.HttpRequest memory request;
        request.method = "POST";
        request.url = _endpoint;
        request.headers = new string[](1);
        request.headers[0] = "Content-Type: application/json";
        request.body = bytes(body);

        bytes memory output = Suave.doHTTPRequest(request);

        JSONParserLib.Item memory item = string(output).parse();
        return item.at('"result"');
    }

    function _getLatestBlockNumber(string memory _rpcEndpoint) private returns (uint256) {
        string memory body = string.concat('{"id": "1", "method":"eth_blockNumber", "jsonrpc":"2.0"}');

        JSONParserLib.Item memory result = _doRequest(_rpcEndpoint, body);

        return JSONParserLib.parseUintFromHex(_stripQuotesAndPrefix(result.value()));
    }

    function _trimQuotes(string memory input) private pure returns (string memory) {
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

    function _stripQuotesAndPrefix(string memory s) private pure returns (string memory) {
        bytes memory strBytes = bytes(s);
        bytes memory result = new bytes(strBytes.length - 4);
        for (uint256 i = 3; i < strBytes.length - 1; i++) {
            result[i - 3] = strBytes[i];
        }
        return string(result);
    }
}

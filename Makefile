include .env

local_run-suave:
	suave-geth --suave.dev --suave.eth.external-whitelist='*' --ipcpath /tmp/geth.ipc
local_deploy-babe:
	forge build
	suave-geth spell deploy Babe.sol:Babe
local_deploy-chatgpt-subnet:
	forge build
	suave-geth spell deploy ChatGPTSubnet.sol:ChatGPTSubnet
local_register-chatgpt-key:
	suave-geth spell conf-request --confidential-input ${CHAT_GPT_KEY} ${CHAT_GPT_SUBNET_ADDR} 'registerKeyOffchain()'
local_register-base-rpc-endpoint:
	suave-geth spell conf-request --confidential-input ${RPC_BASE_SEPOLIA} ${BABE} 'registerEndpointOffchain(uint256)' '(${CHAIN_ID_BASE_SEPOLIA})'
local_monitor-base-sepolia:
	suave-geth spell conf-request ${BABE} 'monitorBabeCalls(uint256,uint256,uint256)' '(${CHAIN_ID_BASE_SEPOLIA}, 0000000900, 100000)'
local_register-signing-key:
	suave-geth spell conf-request --confidential-input ${SIGNING_KEY_WITHOUT_PREFIX} ${BABE} 'registerSigningKey()'

rigil_deploy-babe:
	forge build
	forge create --rpc-url https://rpc.rigil.suave.flashbots.net --legacy --private-key ${DEPLOYER_PK_WITHPREFIX} babe.sol:babe
rigil_deploy-chatgpt-subnet:
	forge build
	forge create --rpc-url https://rpc.rigil.suave.flashbots.net --legacy --private-key ${DEPLOYER_PK_WITHPREFIX} src/subnet/ChatGPTSubnet.sol:ChatGPTSubnet

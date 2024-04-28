include .env

run-suave:
	suave-geth --suave.dev --suave.eth.external-whitelist='*' --ipcpath /tmp/geth.ipc
deploy-babe-locally:
	forge build
	suave-geth spell deploy Babe.sol:Babe
deploy-babe-rigil:
	forge build
	forge create --rpc-url https://rpc.rigil.suave.flashbots.net --legacy --private-key ${DEPLOYER_PK_WITHPREFIX} babe.sol:babe
deploy-chatgpt-subnet-locally:
	forge build
	suave-geth spell deploy ChatGPTSubnet.sol:ChatGPTSubnet
deploy-chatgpt-subnet-rigil:
	forge build
	forge create --rpc-url https://rpc.rigil.suave.flashbots.net --legacy --private-key ${DEPLOYER_PK_WITHPREFIX} ChatGPTSubnet.sol:ChatGPTSubnet
register-chatgpt-key:
	suave-geth spell conf-request --confidential-input ${CHAT_GPT_KEY} ${CHAT_GPT_SUBNET_ADDR} 'registerKeyOffchain()'
register-base-rpc-endpoint:
	suave-geth spell conf-request --confidential-input ${RPC_BASE_SEPOLIA} ${BABE} 'registerEndpointOffchain(uint256)' '(${CHAIN_ID_BASE_SEPOLIA})'
monitor-base-sepolia:
	suave-geth spell conf-request ${BABE} 'monitorBabeCalls(uint256,uint256,uint256)' '(${CHAIN_ID_BASE_SEPOLIA}, 0000000900, 100000)'
register-signing-key:
	suave-geth spell conf-request --confidential-input ${SIGNING_KEY_WITHOUT_PREFIX} ${BABE} 'registerSigningKey()'
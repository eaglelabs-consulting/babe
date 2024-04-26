include .env

run-suave:
	suave-geth --suave.dev --suave.eth.external-whitelist='*' --ipcpath /tmp/geth.ipc
deploy-babe:
	forge build
	suave-geth spell deploy Babe.sol:Babe
deploy-chatgpt-subnet:
	forge build
	suave-geth spell deploy ChatGPTSubnet.sol:ChatGPTSubnet
register-chatgpt-key:
	suave-geth spell conf-request --confidential-input ${CHAT_GPT_KEY} ${CHAT_GPT_SUBNET_ADDR} 'registerKeyOffchain()'
register-base-rpc-endpoint:
	suave-geth spell conf-request --confidential-input ${RPC_BASE_SEPOLIA} ${BABE} 'registerEndpointOffchain(uint256)' '(${CHAIN_ID_BASE_SEPOLIA})'
monitor-base-sepolia:
	suave-geth spell conf-request ${BABE} 'monitorBabeCalls(uint256)' '(${CHAIN_ID_BASE_SEPOLIA})'
add-chatgpt-subnet:
	suave-geth spell conf-request ${BABE} 'setSubnetAddr(uint256,address)' '(0, ${CHAT_GPT_SUBNET_ADDR})'
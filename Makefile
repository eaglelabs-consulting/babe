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
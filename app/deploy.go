package main

import (
	"context"
	"encoding/hex"
	"fmt"
	"log"
	"math/big"
	"os"
	"strconv"

	"github.com/eaglelabs-consulting/babe/framework"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	envconfig "github.com/sethvargo/go-envconfig"
)

type DeploymentConfig struct {
	Environment           string `env:"ENV, default=prod"`
	ChatGPTSubnetContract string `env:"DEPLOYMENT_CHATGPTSUBNET, default=false"`
	BabeContract          string `env:"DEPLOYMENT_BABE, default=false"`
}

func main() {
	var deploymentConfig DeploymentConfig
	var cfg framework.Config
	L1ChainId, _ := strconv.ParseInt(os.Getenv("CHAIN_ID"), 10, 64)

	if err := envconfig.Process(context.Background(), &cfg); err != nil {
		log.Fatal(err)
	}
	if err := envconfig.Process(context.Background(), &deploymentConfig); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("SUAVE Signer Address: %s\n", cfg.FundedAccount.Address())
	fmt.Printf("L1 Signer Address: %s\n", cfg.FundedAccountL1.Address())
	fmt.Printf("L1 RPC: %s\n", cfg.L1RPC)
	fmt.Printf("Kettle RPC: %s\n", cfg.KettleRPC)

	var fr *framework.Framework
	if deploymentConfig.Environment == "prod" {
		fmt.Print("Deploying using SUAVE and L1\n")
		fr = framework.New(framework.WithL1())
		// ethClient := fr.L1.RPC()
	} else {
		fmt.Print("Deploying using local suave-geth\n")
		fr = framework.New()
	}
	suaveChainId, _ := fr.Suave.RPC().ChainID(context.Background())

	var chatgptSubnet *framework.Contract
	if deploymentConfig.ChatGPTSubnetContract == "true" {
		// fetch ChatGPT API key from .env file
		chatgptApiKey := os.Getenv("CHAT_GPT_KEY")

		fmt.Printf("Deploying ChatGPT Subnet with key %s\n", chatgptApiKey)

		chatgptSubnet = fr.Suave.DeployContract("ChatGPTSubnet.sol/ChatGPTSubnet.json")

		// register ChatGPT key using confidential request
		chatgptSubnet.SendConfidentialRequest("registerKeyOffchain", []interface{}{}, []byte(chatgptApiKey))
	} else {
		fmt.Printf("Using ChatGPTSubnet at %s\n", os.Getenv("CHAT_GPT_SUBNET_ADDR"))

		chatgptSubnet = fr.Suave.GetContractAt(common.HexToAddress(os.Getenv("CHAT_GPT_SUBNET_ADDR")), "ChatGPTSubnet.sol/ChatGPTSubnet.json")
	}

	var babe *framework.Contract
	if deploymentConfig.BabeContract == "true" {
		fmt.Printf("Deploying Babe at chain ID %d\n", L1ChainId)

		babe = fr.Suave.DeployContract("Babe.sol/Babe.json")

		// register RPC URL
		fmt.Printf("Registering RPC endpoint\n")
		babe.SendConfidentialRequest("registerEndpointOffchain", []interface{}{big.NewInt(L1ChainId)}, []byte(cfg.L1RPC))

		// register signing key
		fmt.Printf("Registering L1 signer\n")
		skHex := hex.EncodeToString(crypto.FromECDSA(cfg.FundedAccountL1.Priv))
		babe.SendConfidentialRequest("registerSigningKey", []interface{}{}, []byte(skHex))
	} else {
		fmt.Printf("Using Babe at %s\n", os.Getenv("BABE"))

		babe = fr.Suave.GetContractAt(common.HexToAddress(os.Getenv("BABE")), "Babe.sol/Babe.json")
	}

	auth, err := bind.NewKeyedTransactorWithChainID(cfg.FundedAccount.Priv, suaveChainId)
	if err != nil {
		log.Fatalf("Failed to create authorized transactor: %v", err)
	}

	addSubnet(babe, big.NewInt(0), chatgptSubnet.Raw().Address(), fr.Suave.RPC(), auth)

	monitorBabeCalls(cfg.FundedAccount, babe, big.NewInt(L1ChainId), big.NewInt(10000000), big.NewInt(100e10), fr.Suave.RPC(), auth)
}

func addSubnet(contractInstance *framework.Contract, subnetId *big.Int, subnetAddr common.Address, client *ethclient.Client, auth *bind.TransactOpts) (bool, error) {
	contract := bind.NewBoundContract(contractInstance.Raw().Address(), *contractInstance.Abi, client, client, client)

	tx, err := contract.Transact(auth, "setSubnetAddr", subnetId, subnetAddr)
	if err != nil {
		return false, fmt.Errorf("setSubnetAddr transaction failed: %v", err)
	}

	// Wait for the transaction to be included
	fmt.Println("Waiting for the transaction to be included...")
	receipt, err := bind.WaitMined(context.Background(), client, tx)
	if err != nil {
		return false, fmt.Errorf("waiting for the transaction mining failed: %v", err)
	}

	if receipt.Status != types.ReceiptStatusSuccessful {
		log.Printf("Transaction failed: receipt status %v", receipt.Status)
		return false, nil
	}

	fmt.Println("Subnet added successfully, transaction hash:", receipt.TxHash.Hex())
	return true, nil
}

func monitorBabeCalls(privKey *framework.PrivKey, contractInstance *framework.Contract, chainId *big.Int, gas *big.Int, gasPrice *big.Int, client *ethclient.Client, auth *bind.TransactOpts) {
	fmt.Print("Monitoring Babe calls\n")
	// contract := bind.NewBoundContract(contractInstance.Raw().Address(), *contractInstance.Abi, client, client, client)

	// tx, err := contract.Transact(auth, "monitorBabeCalls", chainId, gas, gasPrice)
	// if err != nil {
	// 	return false, fmt.Errorf("monitoring babe calls transaction failed: %v", err)
	// }

	// // Wait for the transaction to be included
	// fmt.Println("Waiting for the monitoring transaction to be included...")
	// receipt, err := bind.WaitMined(context.Background(), client, tx)
	// if err != nil {
	// 	return false, fmt.Errorf("waiting for the monitoring transaction mining failed: %v", err)
	// }

	// if receipt.Status != types.ReceiptStatusSuccessful {
	// 	log.Printf("Monitoring babe calls transaction failed: receipt status %v", receipt.Status)
	// 	return false, nil
	// }

	// fmt.Println("Monitoring done successfully, transaction hash:", receipt.TxHash.Hex())
	// return true, nil

	babeContract := contractInstance.Ref(privKey)
	babeContract.SendConfidentialRequest("monitorBabeCalls", []interface{}{chainId, gas, gasPrice}, nil)

	// kdsEvent := &kds{}
	// if err := kdsEvent.Unpack(receipt.Logs[0]); err != nil {
	// 	panic(err)
	// }
	// s := kdsEvent.s

	// fmt.Println("Monitoring done successfully: %s\n", s)
}

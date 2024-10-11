-include .env
//.PHONY: anvil_deploy

# Deploy function uses 10 levels and 1 ether (in wei) as values for the Merkle tree levels and deposit/withdraw denomination
anvil_deploy:
	forge script script/DeployTornado.s.sol --sig "run(uint8, uint256)" 10 1000000000000000000 --fork-url $(ANVIL_RPC) --broadcast --private-key $(PRIVATE_KEY)

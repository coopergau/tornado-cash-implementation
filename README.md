# Tornado Cash Implementation

## Description

This project is based on the private transaction protocol outlined in the [Tornado Cash Privacy Solution Version 1.4](https://berkeley-defi.github.io/assets/material/Tornado%20Cash%20Whitepaper.pdf) whitepaper by Alexey Pertsev, Roman Semenov, and Roman Storm. The protocol enhances privacy for on-chain transactions by allowing users to deposit Ether from one account and withdraw it anonymously using another account, breaking the link between the two addresses. This is accomplished using a Merkle tree and zk-SNARKs, which ensure the integrity and privacy of transactions without revealing identifying information.

## Notes on things to mention

zkREPL was used to get alot of the values used for Verifier.sol testing
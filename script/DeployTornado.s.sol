// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {Groth16Verifier} from "../src/Verifier.sol";
import {Tornado} from "../src/Tornado.sol";

// Need to doe some forking or something to use testnets with the mimc contract
contract DeployTornado is Script {
    function run() external returns (Tornado) {
        uint8 LEVELS = 10;
        uint256 DENOMINATION = 1 ether;
        address MIMC_CONTRACT_ADDRESS = 0x83584f83f26aF4eDDA9CBe8C730bc87C364b28fe; // Actual contract address that Tornado Cash uses on mainnet
        vm.startBroadcast();
        Groth16Verifier verifier = new Groth16Verifier();
        Tornado tornado = new Tornado(LEVELS, DENOMINATION, MIMC_CONTRACT_ADDRESS, address(verifier));
        vm.stopBroadcast();

        return (tornado);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {Groth16Verifier} from "../src/Verifier.sol";
import {Tornado} from "../src/Tornado.sol";

contract DeployTornado is Script {
    address public constant MIMC_CONTRACT_ADDRESS =
        0x83584f83f26aF4eDDA9CBe8C730bc87C364b28fe; // Actual contract address that Tornado Cash uses on mainnet

    function run(
        uint8 _levels,
        uint256 _denomination
    ) external returns (Tornado, Groth16Verifier) {
        vm.startBroadcast();
        Groth16Verifier verifier = new Groth16Verifier();
        Tornado tornado = new Tornado(
            _levels,
            _denomination,
            MIMC_CONTRACT_ADDRESS,
            address(verifier)
        );
        vm.stopBroadcast();

        return (tornado, verifier);
    }
}

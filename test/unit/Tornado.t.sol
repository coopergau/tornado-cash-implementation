// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployTornado} from "../../script/DeployTornado.s.sol";
import {Tornado} from "../../src/Tornado.sol";

contract TornadoTest is Test {
    Tornado public tornado;

    function setUp() external {
        DeployTornado deployer = new DeployTornado();
        tornado = deployer.run();
    }

    function testPlaceholder() public pure {
        assert(true);
    }

    // Private Function Tests ///////////////////////////////////////
    // Currently the suggested method is to change the functions to public, test them, and then change back to private

    // Test passes
    /*function testCircomAndSoldityHashersAreConsistent() public view {
        bytes32 hashOutput = tornado.hashLeftRight(
            bytes32(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef),
            bytes32(0x2ecc7cab28d34610c27369cc8688581c7ddd283d62e1558121d2ae9fb06eff59)
        );
        // Left side is taken from the witness of the mimc_testing circom circuit
        assertEq(
            bytes32(uint256(11037690320217228127748984262847223129857008190069826932981140511052003371803)), hashOutput
        );
    }*/
}

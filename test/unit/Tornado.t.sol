//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployTornado} from "../../script/DeployTornado.s.sol";
import {Tornado} from "../../src/Tornado.sol";

contract TornadoTest is Test {
    Tornado public tornado;
    address public user = address(1);
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant DENOMINATION = 1 ether;
    uint8 public constant NUM_OF_PREV_ROOTS = 30;
    uint8 public constant LEVELS = 10;

    function setUp() external {
        DeployTornado deployer = new DeployTornado();
        tornado = deployer.run();

        vm.deal(user, STARTING_USER_BALANCE);
    }

    function testDepositUpdatesStateProperly() public {
        // Arrange
        bytes32 commitment = 0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9;
        vm.prank(user);

        // Act
        tornado.deposit{value: DENOMINATION}(commitment);

        // Assert
        uint16 newNextDepositIndex = tornado.getNextDepositIndex();
        uint16 expectedNextDepositIndex = 1;

        bytes32[NUM_OF_PREV_ROOTS] memory storedRoots = tornado.getLastThirtyRoots();
        bytes32 lastStoredRoot = storedRoots[0];
        bytes32[] memory lastTreePath = tornado.getLastTreePath();
        bytes32 expectedLastStoredRoot = lastTreePath[LEVELS];

        assertEq(expectedNextDepositIndex, newNextDepositIndex);
        assert(tornado.getCommitmentUsed(commitment));
        assertEq(expectedLastStoredRoot, lastStoredRoot);
    }

    function testDepositRevertsIfLimitReached() public {
        // Arrange
        bytes32 depositIndexStorageSlot = bytes32(uint256(1));
        uint16 maxDepositIndex = uint16(2 ** LEVELS);
        // Set nextDepositIndex to 2 ** levels
        vm.store(address(tornado), depositIndexStorageSlot, bytes32(uint256(maxDepositIndex)));

        bytes32 commitment = 0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9;
        vm.prank(user);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__MaxDepositsReached.selector);
        tornado.deposit{value: DENOMINATION}(commitment);
    }

    function testDepositRevertsIfCommitmentAlreadyUsed() public {
        // Arrange
        bytes32 commitment = 0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9;
        vm.startPrank(user);
        tornado.deposit{value: DENOMINATION}(commitment);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__CommitmentAlreadyHasADeposit.selector);
        tornado.deposit{value: DENOMINATION}(commitment);
    }

    function testDepositRevertsIfNotProperDenomination() public {
        // Arrange
        bytes32 commitment = 0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9;
        vm.prank(user);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__DepositAmountIsNotProperDenomination.selector);
        tornado.deposit{value: DENOMINATION / 2}(commitment);
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

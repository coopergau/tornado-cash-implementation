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
    bytes32 public constant DEFAULT_COMMITMENT = 0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9;
    bytes32[] public defaultTreePath = [
        DEFAULT_COMMITMENT,
        bytes32(uint256(20713448868418175424144322409427676226485345260817034035814444975821404576305)),
        bytes32(uint256(21367047188874551651727612989379533619735274501855133014242641147101753241692)),
        bytes32(uint256(20982385054949355814173811969552254728300434999375559428726413734041591047712)),
        bytes32(uint256(19330776927849631639464959289765154012661343224744657021760728403387758341480)),
        bytes32(uint256(15781727275120602515443274402038545328751627554047627990450166323735050503170)),
        bytes32(uint256(1325191796844260443619793026124084812475983375030824860587450215754380419371)),
        bytes32(uint256(5058921040446778803755371878648427109753620182804490386439736194235303030200)),
        bytes32(uint256(11504151325042039814319418292839149921440562482695615146536542301146970069384)),
        bytes32(uint256(13765071272852744228689829609629218658390568057748156530111077304197633489072)),
        bytes32(uint256(1020129169085779480232613115173744221347928058487760827286405673185017492392))
    ];

    function setUp() external {
        DeployTornado deployer = new DeployTornado();
        tornado = deployer.run();

        vm.deal(user, STARTING_USER_BALANCE);
    }

    // Deposit //////////////////////////////////////////////////////////
    // Function tests that the following are updated correctly:
    // depositIndex
    // commitmentUsed
    // Merkle root storage
    function testDepositUpdatesStateProperly() public {
        // Act
        vm.prank(user);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);

        // Assert
        uint16 newNextDepositIndex = tornado.getNextDepositIndex();
        uint16 expectedNextDepositIndex = 1;

        bytes32[NUM_OF_PREV_ROOTS] memory storedRoots = tornado.getLastThirtyRoots();
        bytes32 lastStoredRoot = storedRoots[0];
        bytes32[] memory lastTreePath = tornado.getLastTreePath();
        bytes32 expectedLastStoredRoot = lastTreePath[LEVELS];

        assertEq(expectedNextDepositIndex, newNextDepositIndex);
        assert(tornado.getCommitmentUsed(DEFAULT_COMMITMENT));
        assertEq(expectedLastStoredRoot, lastStoredRoot);
    }

    function testDepositRevertsIfLimitReached() public {
        // Arrange
        bytes32 depositIndexStorageSlot = bytes32(uint256(1));
        uint16 maxDepositIndex = uint16(2 ** LEVELS);
        // Set nextDepositIndex to 2 ** levels
        vm.store(address(tornado), depositIndexStorageSlot, bytes32(uint256(maxDepositIndex)));

        // Act & Assert
        vm.prank(user);
        vm.expectRevert(Tornado.Tornado__MaxDepositsReached.selector);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);
    }

    function testDepositRevertsIfCommitmentAlreadyUsed() public {
        // Arrange
        vm.startPrank(user);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__CommitmentAlreadyHasADeposit.selector);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);

        vm.stopPrank();
    }

    function testDepositRevertsIfNotProperDenomination() public {
        // Act & Assert
        vm.prank(user);
        vm.expectRevert(Tornado.Tornado__DepositAmountIsNotProperDenomination.selector);
        tornado.deposit{value: DENOMINATION / 2}(DEFAULT_COMMITMENT);
    }

    function testCreatesHashPathCorrectly() public {
        // Act
        vm.prank(user);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);

        // Assert
        bytes32[] memory actualTreePath = tornado.getLastTreePath();
        assert(actualTreePath.length == defaultTreePath.length);
        for (uint256 i = 0; i < actualTreePath.length; i++) {
            assertEq(actualTreePath[i], defaultTreePath[i]);
        }
    }

    function testEmitDepositWithCorrectArgs() public {
        // Arrange
        uint8[] memory expectedhashDirections = new uint8[](LEVELS);
        for (uint256 i = 0; i < LEVELS; i++) {
            expectedhashDirections[i] = 0;
        }

        // Act & Assert
        vm.expectEmit();
        emit Tornado.Deposit(DEFAULT_COMMITMENT, defaultTreePath, expectedhashDirections);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);
    }

    // Private Function Tests ///////////////////////////////////////
    // Currently the suggested method is to change the functions to public, test them, and then change back to private

    // Test passes
    /*function testCircomAndSoldityHashersAreConsistent() public view {
        bytes32 hashOutput = tornado.hashLeftRight(
            0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef,
            0x2ecc7cab28d34610c27369cc8688581c7ddd283d62e1558121d2ae9fb06eff59
        );
        // Left side is taken from the witness of the mimc_testing circom circuit
        assertEq(
            bytes32(
                uint256(
                    11037690320217228127748984262847223129857008190069826932981140511052003371803
                )
            ),
            hashOutput
        );
    }*/

    // Function used to get the defaultTreePath
    /*function testGetHashValues() public view {
        bytes32 leftInput = 0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9;
        for (uint256 i = 0; i < LEVELS; i++) {
            bytes32 hashOutput = tornado.hashLeftRight(
                leftInput,
                tornado.getInitNodeValue(i)
            );
            console.log(uint256(hashOutput));
            leftInput = hashOutput;
        }
    }*/
}

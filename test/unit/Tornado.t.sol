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
    // This is the commitment produced in the valid proof using the secret and nullifier in circuits/inputs.json
    bytes32 public constant DEFAULT_COMMITMENT =
        bytes32(uint256(21115196571676507868463185879415297057011113699350256184290582436409507128386));
    // Maybe move this into the test function if it only gets used in one
    bytes32[] public defaultTreePath = [
        DEFAULT_COMMITMENT,
        bytes32(uint256(493484653166158114118544147193454987479951749075110207247550850329784053753)),
        bytes32(uint256(6329285957053022111621473872593962239458391357175927705368264896486795703218)),
        bytes32(uint256(9237187072664767464381499128964422466268010906255467325028410159482273910061)),
        bytes32(uint256(9677674646376489025443027910096396312270355907679568295436425862845657308031)),
        bytes32(uint256(1062656661606337925675597792402169590804434156582669230328016431089991199879)),
        bytes32(uint256(11480752392118477789250602079808354202042725946243689443884646470897224147189)),
        bytes32(uint256(14397727338732292485563779603761942941317699640022116873772291528216321115489)),
        bytes32(uint256(3928021846414916357061114320678639866468354590399219867691133329633402658032)),
        bytes32(uint256(596170214794883513201139523733584038081980409039346554539893814798871516871)),
        bytes32(uint256(20861946461624813537475155640919732833752153914675319841350016749338395248463))
    ];
    // Calling "snarkjs generatecall" in the circuits directory generates the
    // valid proof parameters, including the public inputs
    uint256[2] public validA = [
        0x2479321117d0fbcbf086906fe84a851974483731e31b7f9fb955919122222c3f,
        0x195ef012b8cac3d2892c54ce9a755c41eee47411310b8deb6e44d2b2e7a4ec5c
    ];
    uint256[2][2] public validB = [
        [
            0x0b26ddf36cd1f42db8853750d1f8164297c4b4a87d1e92b505a6ab865bbfbb0c,
            0x1a230ed1a1913c4d656c7f57d6c9131b59eaa192cf00bb4b4a3653881c874268
        ],
        [
            0x0ab165dc12c8875771d2ae3254abe5e1f1044da7a9317634368ca27e301d111b,
            0x16d0a52675465da2ecdef0b99e37cbb41da64dfe765d616fc98be29db4ece7d9
        ]
    ];
    uint256[2] public validC = [
        0x278124555bf0c8f17df78b9c59fac8e32d6bc222da9a462fef26b0fb52eb5a84,
        0x2679278d6c3a5fe59d02beb59d6456881ac37420200cb7f2c5361281cdacd4da
    ];
    // Public inputs - Address comes from msg.sender
    bytes32 public validRoot = 0x2e1f71794ec5b81b8d9cfca569c00e42d8ec0d3adee4e0888f6b839c4a9d874f;
    bytes32 public validNullHash = 0x0d27f3b3ac9366f25360e532ea7639b549145aa13b74ee7bf7c3eb34e904c5f4;

    function setUp() external {
        DeployTornado deployer = new DeployTornado();
        (tornado,) = deployer.run();

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

    // Withdraw /////////////////////////////////////////////////////////
    function testWithdrawRevertsIfRootIsNotCurrent() public {
        // Arrange
        bytes32 wrongRoot = bytes32(uint256(validRoot) + 1);
        vm.startPrank(user);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__NotACurrentRoot.selector);
        tornado.withdraw(validA, validB, validC, wrongRoot, validNullHash);
        vm.stopPrank();
    }

    function testWithdrawRevertsIfNullHashAlreadyUsed() public {
        // Arrange
        vm.startPrank(user);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);
        tornado.withdraw(validA, validB, validC, validRoot, validNullHash);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__NullifierAlreadyUsed.selector);
        tornado.withdraw(validA, validB, validC, validRoot, validNullHash);
        vm.stopPrank();
    }

    function testWithdrawRevertsIfProofIsFalse() public {
        // Arrange
        uint256[2] memory invalidA = [validA[0], validA[1] + 1];
        vm.startPrank(user);
        tornado.deposit{value: DENOMINATION}(DEFAULT_COMMITMENT);

        // Act & Assert
        vm.expectRevert(Tornado.Tornado__InvalidWithdrawProof.selector);
        tornado.withdraw(invalidA, validB, validC, validRoot, validNullHash);
        vm.stopPrank();
    }

    // Add more tests for when a value is deposited in the middle of the tree, not the first deposit

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
        bytes32 leftInput = DEFAULT_COMMITMENT;
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

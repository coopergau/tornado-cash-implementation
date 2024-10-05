// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployTornado} from "../../script/DeployTornado.s.sol";
import {Groth16Verifier} from "../../src/Verifier.sol";

contract VerifierTest is Test {
    Groth16Verifier public verifier;

    uint8 public constant LEVELS = 10;
    uint256 public constant DENOMINATION = 1 ether;

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
    // Public inputs
    uint256 public validRoot = 0x2e1f71794ec5b81b8d9cfca569c00e42d8ec0d3adee4e0888f6b839c4a9d874f;
    uint256 public validNullHash = 0x0d27f3b3ac9366f25360e532ea7639b549145aa13b74ee7bf7c3eb34e904c5f4;
    uint256 public validUserAddress = 0x0000000000000000000000000000000000000000000000000000000000000001;

    function setUp() external {
        DeployTornado deployer = new DeployTornado();
        (, verifier) = deployer.run(LEVELS, DENOMINATION);
    }

    //////////////////////////
    // Valid Proof Tests
    //////////////////////////
    function testValidProofReturnsTrue() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];

        // Act
        bool validProof = verifier.verifyProof(validA, validB, validC, pubInputs);

        // Assert
        assert(validProof);
    }

    //////////////////////////
    // Invalid Proof Tests
    //////////////////////////
    function testWrongRootReturnsFalseProof() public view {
        // Arrange
        uint256 wrongRoot = validRoot + 1;
        uint256[3] memory pubInputs = [wrongRoot, validNullHash, validUserAddress];

        // Act
        bool validProof = verifier.verifyProof(validA, validB, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongNullHashReturnsFalseProof() public view {
        // Arrange
        uint256 wrongNullHash = validNullHash + 1;
        uint256[3] memory pubInputs = [validRoot, wrongNullHash, validUserAddress];

        // Act
        bool validProof = verifier.verifyProof(validA, validB, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongAddressReturnsFalseProof() public view {
        // Arrange
        uint256 wrongAddress = validUserAddress + 1;
        uint256[3] memory pubInputs = [validRoot, validNullHash, wrongAddress];

        // Act
        bool validProof = verifier.verifyProof(validA, validB, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongA0ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2] memory wrong_a = [validA[0] + 1, validA[1]];

        // Act
        bool validProof = verifier.verifyProof(wrong_a, validB, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongA1ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2] memory wrong_a = [validA[0], validA[1] + 1];

        // Act
        bool validProof = verifier.verifyProof(wrong_a, validB, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongB00ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2][2] memory wrong_b = [[validB[0][0] + 1, validB[0][1]], [validB[1][0], validB[1][1]]];

        // Act
        bool validProof = verifier.verifyProof(validA, wrong_b, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongB01ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2][2] memory wrong_b = [[validB[0][0], validB[0][1] + 1], [validB[1][0], validB[1][1]]];

        // Act
        bool validProof = verifier.verifyProof(validA, wrong_b, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongB10ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2][2] memory wrong_b = [[validB[0][0], validB[0][1]], [validB[1][0] + 1, validB[1][1]]];

        // Act
        bool validProof = verifier.verifyProof(validA, wrong_b, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongB11ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2][2] memory wrong_b = [[validB[0][0], validB[0][1]], [validB[1][0], validB[1][1] + 1]];

        // Act
        bool validProof = verifier.verifyProof(validA, wrong_b, validC, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongC0ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2] memory wrong_c = [validC[0] + 1, validC[1]];

        // Act
        bool validProof = verifier.verifyProof(validA, validB, wrong_c, pubInputs);

        // Assert
        assert(!validProof);
    }

    function testWrongC1ReturnsFalseProof() public view {
        // Arrange
        uint256[3] memory pubInputs = [validRoot, validNullHash, validUserAddress];
        uint256[2] memory wrong_c = [validC[0], validC[1] + 1];

        // Act
        bool validProof = verifier.verifyProof(validA, validB, wrong_c, pubInputs);

        // Assert
        assert(!validProof);
    }
}

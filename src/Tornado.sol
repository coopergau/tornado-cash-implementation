// Layout of File:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

interface IMiMC {
    function MiMCSponge(uint256 in_xL, uint256 in_xR) external pure returns (uint256 xL, uint256 xR);
}

contract Tornado {
    // Errors ///////////////////////////////////////////////////////////////////////////////////////
    // Can I make this display with the contract denomination
    error Tornado__DepositAmountIsNotProperDenomination();
    error Tornado__CommitmentAlreadyHasADeposit();
    error Tornado__TreeLevelsExceedsTen();
    error Tornado__MaxDepositsReached();
    error Tornado__HashElementNotInField();

    // State Variables //////////////////////////////////////////////////////////////////////////////
    uint8 private constant NUM_OF_PREV_ROOTS = 30;
    uint8 private immutable levels;
    uint8 private immutable denomination;
    IMiMC private immutable mimc;
    mapping(bytes32 => bool) private commitmentsUsed;
    mapping(bytes32 => bool) private nullifierHashesUsed;
    uint16 private nextDepositIndex = 0;
    bytes32[NUM_OF_PREV_ROOTS] lastThirtyRoots;
    bytes32[] lastTreePath;
    // Field modulo from circom lib docs
    uint256 private constant FIELD_MODULUS =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32[10] initialNodeValues = [
        bytes32(0x0de70e2c8239509d2b8be8701de9657180da637f09f4063046f5f3d90b01b5d9),
        bytes32(0x211436a028b38dcd6f02492ea42254a7fe34a03fef3baaddb357156ad84480b1),
        bytes32(0x023e3b895367a1e60223c601d6823a42d78d199e7174c5eb3e4c29cabf7c4dd3),
        bytes32(0x03417128982f9a3eecf227fb511ed46edae71991d68861548b1c081cf35762e3),
        bytes32(0x122caecc4e02fcf1d4867fc71beca700706767c4337a90fdef096ca2a85cd551),
        bytes32(0x2ecc7cab28d34610c27369cc8688581c7ddd283d62e1558121d2ae9fb06eff59),
        bytes32(0x2f5b206c3d94be12e74877e7c2681abb29d41715083fd69a5ef410dc747bf7f0),
        bytes32(0x0047482acf7237ec934584082a5bebcbfec5fb3a47b202de12b8e1ce9f3a38c4),
        bytes32(0x24bf01b2dca343cd72e4d27b4e548d84799b81096aa894c7e825780ff07ea24d),
        bytes32(0x27600a82f00c73b9b35841dbbf3c91362c7127c4016ab9deef248a9da45ba6d0)
    ];

    // Events ///////////////////////////////////////////////////////////////////////////////////////
    event Deposit(bytes32 commitment, bytes32[] treePath, uint8[] hashDirections);

    // Functions ////////////////////////////////////////////////////////////////////////////////////
    constructor(uint8 _levels, uint8 _denomination, IMiMC _mimc) {
        if (_levels > 10) {
            revert Tornado__TreeLevelsExceedsTen();
        }
        levels = _levels;
        denomination = _denomination;
        mimc = _mimc;
    }

    // External Functions ///////////////////////////////////////////////////////////////////////////
    function deposit(bytes32 _commitment) external payable {
        if (nextDepositIndex >= 2 ** levels) {
            revert Tornado__MaxDepositsReached();
        }
        if (commitmentsUsed[_commitment]) {
            revert Tornado__CommitmentAlreadyHasADeposit();
        }
        if (msg.value != denomination) {
            revert Tornado__DepositAmountIsNotProperDenomination();
        }

        uint16 currentIndex = nextDepositIndex;
        bytes32 left;
        bytes32 right;
        uint8[] memory hashDirections; // index of previous hash element in calculation of next hash element
        bytes32[] memory newTreePath;
        newTreePath[0] = _commitment;
        for (uint8 i = 0; i < levels; i++) {
            if (currentIndex % 2 == 0) {
                hashDirections[i] = 0;
                left = newTreePath[i];
                right = initialNodeValues[i];
            } else {
                hashDirections[i] = 1;
                left = lastTreePath[i];
                right = newTreePath[i];
            }
            newTreePath[i + 1] = hashLeftRight(mimc, left, right);
        }
        lastTreePath = newTreePath;

        commitmentsUsed[_commitment] = true;
        lastThirtyRoots[nextDepositIndex % NUM_OF_PREV_ROOTS] = lastTreePath[levels + 1];
        nextDepositIndex++;
        emit Deposit(_commitment, lastTreePath, hashDirections);
    }

    function withdraw() external {}

    // View & Pure Functions //////////////////////////////////////////////////////
    /**
     * @dev Hashes 2 tree nodes
     */
    function hashLeftRight(IMiMC _hasher, bytes32 _left, bytes32 _right) public pure returns (bytes32) {
        if (uint256(_left) > FIELD_MODULUS) {
            revert Tornado__HashElementNotInField();
        }
        if (uint256(_right) > FIELD_MODULUS) {
            revert Tornado__HashElementNotInField();
        }

        uint256 R = uint256(_left);
        uint256 C = 0;
        (R, C) = _hasher.MiMCSponge(R, C);
        R = addmod(R, uint256(_right), FIELD_MODULUS);
        (R, C) = _hasher.MiMCSponge(R, C);
        return bytes32(R);
    }
}

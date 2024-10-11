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
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {console} from "forge-std/console.sol";

interface IMiMC {
    /**
     * @notice Computes the MiMC permutation in the Feistel mode in a sponge mode
     * of operation.
     * @dev Taken from Tornado Cash's MerkleTreeWithHistory.sol contract to interact with the MiMCSonge hasher contract created by the Tornado Cash team.
     * @param in_xL The left Merkle tree node getting hashed.
     * @param in_xR The right Merkle tree node getting hashed.
     * @return xL The left pat of the resulting hash.
     * @return xR The right pat of the resulting hash.
     */
    function MiMCSponge(uint256 in_xL, uint256 in_xR) external pure returns (uint256 xL, uint256 xR);
}

interface IVerifier {
    /**
     * @notice Verifies a zk-SNARK proof that the prover knows a secret and a nullifier that hash to
     * produce a commitment that is currently in the Merkle tree
     * @dev This function comes from the Verfier.sol contract, generated using snarkjs
     * @param _pA The first part of the zk-SNARK proof, one elliptic curve point.
     * @param _pB The second part of the zk-SNARK proof, two elliptic curve points.
     * @param _pC The third part of the zk-SNARK proof, one elliptic curve point.
     * @param _pubSignals Public signals used in the proof in the form: [root, nullifierHash, address].
     * @return bool True if the proof is valid, false otherwise.
     */
    function verifyProof(
        uint256[2] memory _pA,
        uint256[2][2] memory _pB,
        uint256[2] memory _pC,
        uint256[3] memory _pubSignals
    ) external view returns (bool);
}

/**
 * @title Tornado Cash Implimentation
 * @author Cooper Gau
 * @notice This contract was created solely for educational purposes to explore and understand
 *         certain concepts of smart contracts, cryptography, and zero knowledge proofs, through an
 *         implimentation of the Tornado Cash protocol.
 * @dev This implementation is not intended for actual use in production environments. Users should be
 *      aware of the recent sanctions imposed on Tornado Cash and related entities. This contract
 *      does not represent a functioning or compliant version of the Tornado Cash protocol. It is a
 *      learning tool intended to display an understanding of privacy-preserving technologies in
 *      blockchain systems.
 */
contract Tornado is ReentrancyGuard {
    //////////////////////
    // Errors
    //////////////////////
    error Tornado__MaxDepositsReached();
    error Tornado__DepositAmountIsNotProperDenomination();
    error Tornado__CommitmentAlreadyHasADeposit();
    error Tornado__TreeLevelsExceedsTen();
    error Tornado__HashElementNotInField();
    error Tornado__NotACurrentRoot();
    error Tornado__NullifierAlreadyUsed();
    error Tornado__InvalidWithdrawProof();
    error Tornado__WithdrawFailed();

    //////////////////////
    // State Variables
    //////////////////////

    // Constants
    uint8 internal constant NUM_OF_PREV_ROOTS = 30;
    // Field modulus from circom lib docs
    uint256 internal constant FIELD_MODULUS =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    // Immutables
    uint8 internal immutable levels;
    uint256 internal immutable denomination;
    IMiMC internal immutable mimc;
    IVerifier internal immutable verifier;

    // Variables
    uint16 internal nextDepositIndex = 0;
    bytes32[NUM_OF_PREV_ROOTS] internal lastThirtyRoots;
    bytes32[] internal lastTreePath;

    // Mappings
    mapping(bytes32 => bool) internal commitmentsUsed;
    mapping(bytes32 => bool) internal nullifierHashesUsed;

    // Randomly generated Merkle tree initial node values by level
    bytes32[10] internal initialNodeValues = [
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

    //////////////////////
    // Events
    //////////////////////
    /**
     * @notice When a user makes a deposit, this event emits the information the user will later
     *         need to contruct a valid withdraw proof
     * @dev The user doesn't need to do record any of this, it's all retrieved by the frontend
     * @param commitment The Pederson commitment that was just added to the Merkle tree
     * @param treePath The path of Merkle tree nodes going from the commitment to the new root
     * @param hashDirections An array indicating the positions of the previous treePath elements
     *                       in the hashing process for the next treePath element. A value of 0
     *                       indicates that the previous element is the left input for the hashing,
     *                       while a value of 1 indicates it is the right input. (e.g. The
     *                       hashDirections array for the first deposit will be all zeros)
     */
    event Deposit(bytes32 commitment, bytes32[] treePath, uint8[] hashDirections);
    /**
     * @notice When a user withdraws funds, this event emits the hash of the nullifier
     *         that is used to prevent double spending of the same commitment.
     * @param nullifierHash The hash of the nullifier.
     */
    event Withdraw(bytes32 nullifierHash);

    //////////////////////
    // Functions
    //////////////////////
    /**
     * @param _levels The levels of the Merkle tree, not including the root.
     * @param _denomination The amount of wei that users can deposit or withdraw per transaction.
     * @param _mimc The address of the MiMC contract.
     * @param _verifier The address of the verifier contract.
     */
    constructor(uint8 _levels, uint256 _denomination, address _mimc, address _verifier) {
        if (_levels > 10) {
            revert Tornado__TreeLevelsExceedsTen();
        }
        levels = _levels;
        denomination = _denomination;
        mimc = IMiMC(_mimc);
        verifier = IVerifier(_verifier);
    }

    //////////////////////
    // External Functions
    //////////////////////
    /**
     * @notice Function deposits funds into the contract, adds the associated commitment to the
     *         next available Merkle tree leaf node, and updates the state of the Merkle tree accordingly.
     * @dev Reverts if there are no more available leaf nodes, the commitment is already associated with
     *      a deposit, or an incorrect amount of ether is sent.
     * @dev Emits Deposit event.
     * @param _commitment The Pederson commitment associated with this deposit.
     */
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
        /* hashDirections: index of the last hash element in the calculation of next hash element 
           0 -> left input, 1 -> right input */
        uint8[] memory hashDirections = new uint8[](levels);
        bytes32[] memory newTreePath = new bytes32[](levels + 1);
        newTreePath[0] = _commitment;

        // Calculate new path form the commitment to the Merkle root
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
            newTreePath[i + 1] = hashLeftRight(left, right);
            currentIndex /= 2;
        }
        lastTreePath = newTreePath;

        // Update Merkle root
        lastThirtyRoots[nextDepositIndex % NUM_OF_PREV_ROOTS] = lastTreePath[levels];

        // Update array of commitments used and Merkle tree deposit index
        commitmentsUsed[_commitment] = true;
        nextDepositIndex++;
        emit Deposit(_commitment, lastTreePath, hashDirections);
    }

    /**
     * @notice Function evalutes a proof that the user knows a secret and a nullifier that are associated with
     *         a commitment used to deposit ether into the contract. If the proof is valid and has not been used
     *         before, the function sends the user the ether associated with that commitment.
     * @dev The proof proves that the commitment is currently a leaf node in the Merkle tree.
     * @dev Reverts if the proof is invalid, the proof isn't using the current Merkle root, or the proof has
     *      has already been used.
     * @param _pA The first part of the zk-SNARK proof, one elliptic curve point.
     * @param _pB The second part of the zk-SNARK proof, two elliptic curve points.
     * @param _pC The third part of the zk-SNARK proof, one elliptic curve point.
     * @param _root The Merkle root used in the proof.
     * @param _nullifierHash The hash of the nullifier used in the proof.
     */
    function withdraw(
        uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        bytes32 _root,
        bytes32 _nullifierHash
    ) external nonReentrant {
        if (!validRoot(_root)) {
            revert Tornado__NotACurrentRoot();
        }
        if (nullifierHashesUsed[_nullifierHash]) {
            revert Tornado__NullifierAlreadyUsed();
        }
        if (
            !verifier.verifyProof(_pA, _pB, _pC, [uint256(_root), uint256(_nullifierHash), uint256(uint160(msg.sender))])
        ) {
            revert Tornado__InvalidWithdrawProof();
        }

        nullifierHashesUsed[_nullifierHash] = true;

        (bool withdrawSuccess,) = msg.sender.call{value: denomination}("");
        if (!withdrawSuccess) {
            revert Tornado__WithdrawFailed();
        }

        emit Withdraw(_nullifierHash);
    }

    /////////////////////////
    // View & Pure Functions
    /////////////////////////
    /**
     * @dev Function is essentially the MiMC Sponge Hash function used for hashing
     *         Merkle tree nodes
     * @dev This contract uses the MiMCSponge hasher contract made by the Tornado Cash team, so this function
     *      was taken directly from their MerkleTreeWithHistory.sol contract.
     * @param _left Left hash input node.
     * @param _right Right hash input node.
     * @return R The output of the MiMC hash function. The Merkle tree node of the next level or if it is the
     * final level, the Merkle root.
     */
    function hashLeftRight(bytes32 _left, bytes32 _right) private view returns (bytes32) {
        if (uint256(_left) > FIELD_MODULUS) {
            revert Tornado__HashElementNotInField();
        }
        if (uint256(_right) > FIELD_MODULUS) {
            revert Tornado__HashElementNotInField();
        }

        uint256 R = uint256(_left);
        uint256 C = 0;
        (R, C) = mimc.MiMCSponge(R, C);
        R = addmod(R, uint256(_right), FIELD_MODULUS);
        (R, C) = mimc.MiMCSponge(R, C);
        return bytes32(R);
    }

    /**
     * @dev Function checks if the given root is one of the previous 30 Merkle roots. This is necessary
     *      because the withdrawal process requires the prover to retrieve data from emitted events, create
     *      the withdrawal proof, and submit the proof for verification. During this time, it is possible
     *      for other users to submit deposits, which would change the current Merkle root. Allowing proofs
     *      against the previous 30 roots helps prevent valid proofs from getting rejected.
     */
    function validRoot(bytes32 _root) internal view returns (bool) {
        for (uint256 i = 0; i < lastThirtyRoots.length; i++) {
            if (lastThirtyRoots[i] == _root) {
                return true;
            }
        }
        return false;
    }

    // Getter Functions
    function getNextDepositIndex() public view returns (uint16) {
        return nextDepositIndex;
    }

    function getCommitmentUsed(bytes32 _commitment) public view returns (bool) {
        return commitmentsUsed[_commitment];
    }

    function getNumOfPrevRoots() public pure returns (uint8) {
        return NUM_OF_PREV_ROOTS;
    }

    function getLastThirtyRoots() public view returns (bytes32[NUM_OF_PREV_ROOTS] memory) {
        return lastThirtyRoots;
    }

    function getLastTreePath() public view returns (bytes32[] memory) {
        return lastTreePath;
    }

    function getInitNodeValue(uint256 i) public view returns (bytes32) {
        return initialNodeValues[i];
    }

    function getNullHashUsed(bytes32 _nullHash) public view returns (bool) {
        return nullifierHashesUsed[_nullHash];
    }
}

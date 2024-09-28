pragma circom 2.1.9;

include "../node_modules/circomlib/circuits/pedersen.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template Withdraw(levels) {
    // Public inputs
    signal input _root;
    signal input _nullifierHash;
    signal input _address;

    // Private inputs
    signal input secret[256];
    signal input nullifier[256];
    signal input siblingNodes[levels];
    signal input hashDirections[levels];
    
    // Verify the nullifier hash
    component nullHasher = Pedersen(256);
    nullHasher.in <== nullifier;    
    signal nullHashed <== nullHasher.out[0];
    _nullifierHash === nullHashed;

    // Verify the merkle root
    signal concat[512];
    for (var i = 0; i < 256; i++) {
        concat[i] <== nullifier[i];
        concat[256 + i] <== nullifier[i];
    }
    component commitmentHasher = Pedersen(512);
    commitmentHasher.in <== concat;
    signal rootPath[levels + 1];
    rootPath[0] <== commitmentHasher.out[0];

    signal left[levels];
    signal right[levels];
    component mimcHashers[levels];

    for (var i = 0; i < levels; i++) {
        mimcHashers[i] = MiMCSponge(2, 220, 1);
        mimcHashers[i].k <== 0;
        left[i] <== (1 - hashDirections[i]) * rootPath[i];
        mimcHashers[i].ins[0] <== left[i] + (hashDirections[i] * siblingNodes[i]);
        right[i] <== (1 - hashDirections[i]) * siblingNodes[i];
        mimcHashers[i].ins[1] <== right[i] + (hashDirections[i] * rootPath[i]);

        rootPath[i+1] <== mimcHashers[i].outs[0];
    }
    _root === rootPath[levels];

    // This is to prevent MEV attacks
    signal addressSquared;
    addressSquared <== _address * _address;
}

component main {public [_root, _nullifierHash, _address]} = Withdraw(10);
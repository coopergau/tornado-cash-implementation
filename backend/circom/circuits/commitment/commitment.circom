// Generate the commitment for the frotnend use
pragma circom 2.1.9;

include "../../node_modules/circomlib/circuits/pedersen.circom";

template commitment() {
    signal input secret[256];
    signal input nullifier[256];
    signal output commitment;
    
    signal concat[512];
    for (var i = 0; i < 256; i++) {
        concat[i] <== nullifier[i];
        concat[256 + i] <== secret[i];
    }
    component commitmentHasher = Pedersen(512);
    commitmentHasher.in <== concat;
    commitment <== commitmentHasher.out[0];
}

component main {public [secret, nullifier]} = commitment();
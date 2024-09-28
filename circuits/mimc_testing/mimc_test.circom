pragma circom 2.1.9;

include "../../node_modules/circomlib/circuits/mimcsponge.circom";

// This circuit is used to compare the circomlib mimc hash function output to the smart contract mimc hash function output 
template mimc_test() {
    // random field elements
    signal input left;
    signal input right;
    signal output hashResult;
    
    component mimcHasher = MiMCSponge(2, 220, 1);
    mimcHasher.k <== 0;
    mimcHasher.ins[0] <== left;
    mimcHasher.ins[1] <== right;
    hashResult <== mimcHasher.outs[0];
}

component main = mimc_test();
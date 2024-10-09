// Converts bigint into 256 bits
// Used to convert the secret and nullifier to bits for inputing into circom circuits

function bigintToBits(bigint) {
    const binaryString = bigint.toString(2).padStart(256, '0');;
    const bits = binaryString.split('').map(bit => parseInt(bit, 10));
    return bits;
  }

export default bigintToBits;
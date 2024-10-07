// Generate a random uint256 within the circomlib field size

const FIELD_SIZE = BigInt("21888242871839275222246405745257275088548364400416034343698204186575808495617");

const generateSecretAndNull = () => {
    const uintArray = new Uint32Array(16);
    window.crypto.getRandomValues(uintArray);

    // Convert the first half of the array into the secret
    let secret = BigInt(0);
    for (let i = 0; i < 8; i++) {
        secret = (secret << BigInt(32)) + BigInt(uintArray[i]);
    }

    // Convert the second half of the array into the nullifier
    let nullifier = BigInt(0);
    for (let i = 8; i < 16; i++) {
        nullifier = (nullifier << BigInt(32)) + BigInt(uintArray[i]);
    }

    // Make sure both numbers are in the field
    return [secret % FIELD_SIZE, nullifier % FIELD_SIZE];
};

export default generateSecretAndNull;
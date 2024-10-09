// File computes the commitment from a given secret and nullifier, using the compiled commitment circuit
import * as snarkjs from 'snarkjs';
import wtnsCalculate from '../../node_modules/snarkjs/src/wtns_calculate.js';
import wtnsExportJson from '../../node_modules/snarkjs/src/wtns_export_json.js';
import bigintToBits from './bigintToBits.js';

async function getCommitment(secret, nullifier) {
    // Convert both inputs to bits
    const secretBits = bigintToBits(secret);
    const nullifierBits = bigintToBits(nullifier);
    const circuitInput = { secret: secretBits, nullifier: nullifierBits };

    // Paths to ci
    const witnessPath = '../../../backend/circom/circuits/commitment/commitment_js/commitment.wasm';
    const witnessFile = './out.wtns'
    
    await wtnsCalculate(circuitInput, witnessPath, witnessFile);
    const witnessJson = await wtnsExportJson(witnessFile);
    return witnessJson
}

const s = 8;
const n = 256;
const res = await getCommitment(s, n);
console.log(res);

//export default getCommitment;

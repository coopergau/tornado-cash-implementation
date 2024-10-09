// File computes the commitment from a given secret and nullifier, using the compiled commitment circuit
import * as snarkjs from 'snarkjs';
import wtnsCalculate from '../../node_modules/snarkjs/src/wtns_calculate.js';
import wtnsExportJson from '../../node_modules/snarkjs/src/wtns_export_json.js';
import bigintToBits from './bigintToBits.js';
import myWtnsCalculate from './myWitnessGenerator.js';

async function getCommitment(secret, nullifier) {
    // Convert both inputs to bits
    const secretBits = bigintToBits(secret);
    const nullifierBits = bigintToBits(nullifier);
    const circuitInput = { secret: secretBits, nullifier: nullifierBits };

    // Path to wasm file for witness creation
    const witnessPath = '../../../backend/circom/circuits/commitment/commitment_js/commitment.wasm';
    
    // Generate witness
    const witness = await myWtnsCalculate(circuitInput, witnessPath);
    const witnessJson = await wtnsExportJson(witness);
    return witnessJson
}

const s = 8;
const n = 10;
const res = await getCommitment(s, n);
console.log(res);

//export default getCommitment;

// This is an edit of the wtns_calculate.js file from snarkjs node_modules
// This version returns the witness as a variable instead of creating a file

import * as fastFile from "fastfile";
import { WitnessCalculatorBuilder } from "circom_runtime";
import * as wtnsUtils from "../../node_modules/snarkjs/src/wtns_utils.js";
import * as binFileUtils from "@iden3/binfileutils";
import {  utils }   from "ffjavascript";
const { unstringifyBigInts} = utils;

async function myWtnsCalculate(_input, wasmFileName) {
    const input = unstringifyBigInts(_input);

    const fdWasm = await fastFile.readExisting(wasmFileName);
    const wasm = await fdWasm.read(fdWasm.totalSize);
    await fdWasm.close();

    const wc = await WitnessCalculatorBuilder(wasm);
    if (wc.circom_version() == 1) {
        const w = await wc.calculateBinWitness(input);

        // const fdWtns = await binFileUtils.createBinFile(wtnsFileName, "wtns", 2, 2);

        await wtnsUtils.writeBin(fdWtns, w, wc.prime);
        await fdWtns.close();
    } else {
        // const fdWtns = await fastFile.createOverride(wtnsFileName);

        const w = await wc.calculateWTNSBin(input);

        // await fdWtns.write(w);
        // await fdWtns.close();
        return w
    }
}

export default myWtnsCalculate;

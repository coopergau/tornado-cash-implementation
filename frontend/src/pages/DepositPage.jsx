import { useNavigate } from 'react-router-dom/dist';
import { useState, useEffect } from 'react';
import generateSecretAndNull from '../utils/rng';
import connectMetaMask from '../utils/connectMetaMask';
import checkMetaMaskConnection from '../utils/checkMetaMaskConnection';

function DepositPage() {
    const [actualSecretAndNull, setActual] = useState([0n, 0n]);
    const [exampleSecretAndNull, setExSecretAndNull] = useState([0n, 0n]);
    const [secretInput, setSecretInput] = useState('');
    const [nullInput, setNullInput] = useState('');

    const { account, network, isConnected, isAnvilNetwork } = checkMetaMaskConnection();

    const navigate = useNavigate();

    function getNewSecretAndNull() {
        setExSecretAndNull(generateSecretAndNull());
    }

    function handleSecretInput(num) {
        setSecretInput(num.target.value);
    }

    function handleNullInput(num) {
        setNullInput(num.target.value);
    }

    function useExampleValues() {
        setActual(exampleSecretAndNull);
    }

    function useInputValues() {
        setActual([secretInput, nullInput]);
    }

    async function handleDeposit() {
        if (!isConnected) {
            await connectMetaMask();
        }

        if (!isAnvilNetwork) {
            alert('This requires you to be connected to the anvil network. See https://github.com/coopergau/tornado-cash-implementation/blob/master/README.md for more details.')
            return;
        }

        alert('ye');
    }

    return (
        <div>
            <button onClick={() => getNewSecretAndNull()}>Generate new secret and nullifier</button>
            <button onClick={() => navigate('/')}>Back</button>
            <p>Secret: {exampleSecretAndNull[0].toString()}</p>
            <p>Nullifier: {exampleSecretAndNull[1].toString()}</p>
            <button onClick={() => useExampleValues()}>Use generated values</button>
            <p>Or enter your own numbers</p>
            <label>
                Enter Secret
                <input
                    type="number"
                    onChange={handleSecretInput}
                />
            </label>
            <label>
                Enter Nullifier
                <input
                    type="number"
                    onChange={handleNullInput}
                />
            </label>
            <button onClick={() => useInputValues()}>Use submitted values</button>
            <p>Submitted Secret: {actualSecretAndNull[0].toString()}</p>
            <p>Submitted Nullifier: {actualSecretAndNull[1].toString()}</p>

            <button onClick={() => handleDeposit()}>Deposit ETH</button>
        </div>
    );
};

export default DepositPage;

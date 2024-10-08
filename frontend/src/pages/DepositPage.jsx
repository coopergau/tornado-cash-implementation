import { useNavigate } from 'react-router-dom/dist';
import { useState } from 'react';
import generateSecretAndNull from '../utils/rng';

function DepositPage() {
    const [secretAndNull, setSecretAndNull] = useState([0n, 0n]);
    const [secretInput, setSecret] = useState('');
    const [nullInput, setNull] = useState('');
    const navigate = useNavigate();

    function handleSecret(num) {
        setSecret(num)
    }

    function handleNull(num) {
        setNull(num)
    }

    return (
        <div>
            <button onClick={() => setSecretAndNull(generateSecretAndNull())}>Generate new secret and nullifier</button>
            <button onClick={() => navigate('/')}>Back</button>
            <p>Secret: {secretAndNull[0].toString()}</p>
            <p>Nullifier: {secretAndNull[1].toString()}</p>
            <label>
                Enter Secret
                <input
                    type="number"
                    defaultValue={'0'}
                    onChange={handleSecret}
                    min="0"
                    step="1"
                />
            </label>
            <label>
                Enter Nullifier
                <input
                    type="number"
                    defaultValue={'0'}
                    onChange={handleNull}
                    min="0"
                    step="1"
                />
            </label>
        </div>
    );
};

export default DepositPage;

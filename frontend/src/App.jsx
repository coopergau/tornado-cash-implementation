import './App.css';
import { useState } from 'react';
import generateSecretAndNull from './components/rng';


const App = () => {

  const [pageState, setCurrentState] = useState('home');
  const [secretAndNull, setSecretAndNull] = useState([0n, 0n])

  // Function makes sure that the secret and nullifier are set to zero when deposit button is clicked.
  // This is just in case a user goes back and forth between the page states.
  const goToDeposit = () => {
    setSecretAndNull([0n, 0n]);
    setCurrentState('deposit');
  };

  return (
    <div className="container">
      <h1 className="title">Tornado Cash Implementation</h1>

      {pageState === 'home' && (
        <div>
          <button className="deposit" onClick={goToDeposit}>Deposit</button>
          <button className="withdraw" onClick={() => setCurrentState('withdraw')}>Withdraw</button>
        </div>
      )}

      {pageState === 'deposit' && (
        <div>
          <button className="back" onClick={() => setCurrentState('home')}>Back</button>
          <button className="rng" onClick={() => setSecretAndNull(generateSecretAndNull())}>Generate new secret and nullifier</button>
          <p>Secret: {secretAndNull[0].toString()}</p>
          <p>Nullifier: {secretAndNull[1].toString()}</p>
        </div>
      )}

      {pageState === 'withdraw' && (
        <div>
          <button className="back" onClick={() => setCurrentState('home')}>Back</button>
        </div>
      )}

      <p>{pageState}</p>
    </div>
  );
}

export default App;


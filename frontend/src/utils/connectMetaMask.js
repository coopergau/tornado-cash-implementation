// Connect user MetMask wallet

async function connectMetaMask() {
    if (window.ethereum) {
        try {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        } catch (error) {
            console.error('MetaMask connection attempt failed', error);
        }
    } else {
        alert('MetaMask is not installed');
    }
}

export default connectMetaMask;
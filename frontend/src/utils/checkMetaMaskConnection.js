// Checks if a MetaMask wallet is connected and is using the locl anvil network
import { useEffect, useState } from 'react';

const ANVIL_CHAIN_ID = '0x7a69';

function checkMetaMaskConnection() {
    const [account, setAccount] = useState(null);
    const [network, setNetwork] = useState(null);
    const [isConnected, setIsConnected] = useState(false);
    const [isAnvilNetwork, setIsAnvilNetwork] = useState(false);

    useEffect(() => {
        async function initializeConnection() {
            if (window.ethereum) {
                const accounts = await window.ethereum.request({ method: 'eth_accounts' });
                const chainId = await window.ethereum.request({ method: 'eth_chainId' });
                if (accounts.length > 0) {
                    setAccount(accounts[0]);
                    setNetwork(chainId);
                    setIsConnected(true);
                    setIsAnvilNetwork(chainId === ANVIL_CHAIN_ID);
                } else {
                    setIsConnected(false);
                }
            }
        }

        async function handleAccountsChanged(accounts) {
            if (accounts.length > 0) {
                const chainId = await window.ethereum.request({ method: 'eth_chainId' });
                setAccount(accounts[0]);
                setIsConnected(true);
                setNetwork(chainId);
                setIsAnvilNetwork(network === ANVIL_CHAIN_ID);
            } else {
                setAccount(null);
                setNetwork(null);
                setIsConnected(false);
            }
        }

        async function handleChainChanged(chainId) {
            setNetwork(chainId);
            setIsAnvilNetwork(chainId === ANVIL_CHAIN_ID);

            if (chainId !== ANVIL_CHAIN_ID) {
                alert('You have switched to a different network. This requires you to be connected to the Anvil network.');
            }
        }

        initializeConnection();
        window.ethereum.on('accountsChanged', handleAccountsChanged);
        window.ethereum.on('chainChanged', handleChainChanged);

        return () => {
            window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
            window.ethereum.removeListener('chainChanged', handleChainChanged);
        };
    }, []);

    return { account, network, isConnected, isAnvilNetwork };
};

export default checkMetaMaskConnection;

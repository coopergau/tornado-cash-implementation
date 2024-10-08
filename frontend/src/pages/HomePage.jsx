import { useNavigate } from 'react-router-dom/dist';

function HomePage() {
    const navigate = useNavigate();

    return (
        <div>
            <button onClick={() => navigate('/deposit')}>Deposit</button>
            <button onClick={() => navigate('/withdraw')}>Withdraw</button>
        </div>
    );
};

export default HomePage;

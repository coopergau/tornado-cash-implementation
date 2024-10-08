import { useNavigate } from 'react-router-dom/dist';

function WithdrawPage() {
    const navigate = useNavigate();

    return (
        <div>
            <button onClick={() => navigate('/')}>Back</button>
        </div>
    );
};

export default WithdrawPage;

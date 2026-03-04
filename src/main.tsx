import ReactDom from 'react-dom/client';
import { App } from '@/app/App';

const root = document.getElementById('root');

ReactDom.createRoot(root!).render(<App />);

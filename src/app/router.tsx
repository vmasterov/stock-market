import { createBrowserRouter } from 'react-router-dom';
import MarketPage from '@/pages/MarketPage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <MarketPage />,
  },
  {
    path: '/wishlist',
    lazy: async () => ({ Component: (await import('@/pages/WishlistPage')).default }),
  },
]);

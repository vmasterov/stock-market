import ReactDom from 'react-dom/client';
import React from 'react';

const root = document.getElementById('root');

const app = (
  <React.StrictMode>
    <h1>Hello world</h1>
  </React.StrictMode>
);

ReactDom.createRoot(root!).render(app);

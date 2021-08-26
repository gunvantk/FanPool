import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import LandingPage from './components/landing-page/LandinPage';

ReactDOM.render(
  <React.StrictMode>
    <div className="min-h-screen bg-gradient-to-b from-green-800 to-green-400">
      <LandingPage />
    </div>
  </React.StrictMode>,
  document.getElementById('root')
);

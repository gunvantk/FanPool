import React from 'react';
import ReactDOM from 'react-dom';
import {
  BrowserRouter as Router,
  Switch,
  Route
} from "react-router-dom";
import './index.css';
import NavBar from './components/nav-bar/NavBar';
import LandingPage from './components/landing-page/LandinPage';
import {DAppProvider} from '@usedapp/core'
import OnBoardCreator from './components/on-board-creator';
import CreatorList from './components/creator-list';

ReactDOM.render(
  <React.StrictMode>
    <div className="min-h-screen bg-gradient-to-b from-green-800 to-green-400">
      <div className="container">
        <DAppProvider config={{}}>
          <NavBar/>
        </DAppProvider>
          <Router>
            <Switch>
                <Route path="/on-board" component={OnBoardCreator}/>
                <Route path="/creators" component={CreatorList}/>
                <Route path="/" component={LandingPage}/>
            </Switch>
          </Router>
        </div>
    </div>
  </React.StrictMode>,
  document.getElementById('root')
);

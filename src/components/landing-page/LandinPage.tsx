import React from 'react';
import NavBar from '../nav-bar/NavBar';
import HeroBanner from '../hero-banner'
import TopList from '../top-list';
function LandingPage() {
    return (
        <>
        <div className="container ">
        <NavBar/>
        <HeroBanner/>
        <TopList/>
        </div>
        </>
    );
  }
  
  export default LandingPage;
  
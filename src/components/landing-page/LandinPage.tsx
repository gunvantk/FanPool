import React from 'react';
import HeroBanner from '../hero-banner'
import TopList from '../top-list';

function LandingPage() {
    return (
        <>
            <HeroBanner message="Support your favourite creator by staking your eth."/>
            <TopList/>
        </>
    );
  }
  
  export default LandingPage;
  
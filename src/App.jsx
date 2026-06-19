
import { ResonanceProvider } from '@gumgum/resonance'
import defaultFoundation from '@gumgum/resonance/foundation.json'
import '@gumgum/resonance/styles.css'
import React from 'react'

import './App.css'
import Welcome from './Welcome'
import Dashboard from './Dashboard'

function App() {

  return (
    <ResonanceProvider foundation={defaultFoundation}>    
      <div className="wrapper"> 
      <Welcome />
      <Dashboard />
      </div>
    </ResonanceProvider>
  )
}

export default App

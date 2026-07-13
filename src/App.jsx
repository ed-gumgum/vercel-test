
import { ResonanceProvider } from '@gumgum/resonance'
import defaultFoundation from '@gumgum/resonance/foundation.json'
import '@gumgum/resonance/styles.css'

import './App.css'
import Welcome from './Welcome'
import Dashboard from './Dashboard'
import SupabaseData from './SupabaseData'

function App() {

  return (
    <ResonanceProvider foundation={defaultFoundation}>    
      <div className="wrapper"> 
      <Welcome />
      <Dashboard />
      <SupabaseData />
      </div>
    </ResonanceProvider>
  )
}

export default App

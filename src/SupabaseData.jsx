import supabase from './config/superbaseConfig'
import {useEffect, useState} from 'react'
import {Heading, Table, Button} from '@gumgum/resonance'

function SupabaseData() {

  const [dataItems, setDataItems] = useState([]);
  const [newDataItem, setNewDataItem] = useState({name: '', age: 0, owner_id: null});
  const [fetchError, setFetchError] = useState(null);
  const [user, setUser] = useState(null);
  const [session, setSession] = useState(null);
  const [authError, setAuthError] = useState(null);

  const showOwnerId = import.meta.env.DEV;

  useEffect(() => {
    const fetchData = async () => {
      const {data, error} = await supabase.from('Test').select()
      if (error) {
        setFetchError(error)
        setDataItems([])
      } else {
        setDataItems(data)
        setFetchError(null)
      }
    }

    fetchData()
  }, [])

  useEffect(() => {
    let ignore = false

    const loadUser = async () => {
      const {data, error} = await supabase.auth.getSession()

      console.log('loadUser', data)

      if (!ignore) {
        setSession(data.session)
        setUser(data.session?.user ?? null)
        setAuthError(error)
      }
    }

    loadUser()

    const {data} = supabase.auth.onAuthStateChange((event, session) => {
      setSession(session)
      setUser(session?.user ?? null)
      setAuthError(null)
    })

    return () => {
      ignore = true
      data.subscription.unsubscribe()
    }
  }, [])

  const submitItems = async (event) => {
    console.log(newDataItem)
    event.preventDefault();
    const itemToInsert = {
      ...newDataItem,
      owner_id: user?.id || null,
    }

    const {data, error} = await supabase.from('Test').insert(itemToInsert).select()
    if (error) {
      setFetchError(error)
    } else {
      setDataItems([...dataItems, data[0]])
      setNewDataItem({name: '', age: 0, owner_id: null})
      setFetchError(null)
    }
  }

  const deleteItems = async (id) => {
    const {error} = await supabase.from('Test').delete().eq('id', id)
    if (error) {
      setFetchError(error)
    } else {
      setDataItems(dataItems.filter(item => item.id !== id))
      setFetchError(null)
    }
  } 

  const login = async () => {
    setAuthError(null)

    const {error} = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin,
        queryParams: {
          prompt: 'select_account',
        },
      },
    })

    if (error) {
      setAuthError(error)
    }
  }

  const callUserFunction = async () => {
    if (!session?.access_token) {
      setAuthError(new Error('Log in before calling the user-protected function.'))
      return
    }

    const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/set-value-user`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Aimie',
        key: 'age',
        value: '40',
      }),
    })

    const result = await response.json()

    if (!response.ok) {
      setFetchError(new Error(result.error || 'Function request failed.'))
      return
    }

    setFetchError(null)
    console.log(result)
  }

  return (
    <>
    <Heading as="h2">Supabase Data</Heading>
    <div className="logged-in">
      {user?.email ? <div><p>Logged in as: {user.email}</p><Button intent="secondary" onClick={() => supabase.auth.signOut()}>Log out</Button></div> : <Button intent="secondary" onClick={() => login()}>Log in with Google</Button>}
      {user?.email && <Button intent="secondary" onClick={callUserFunction}>Call User Function</Button>}
      {authError && <p>{authError.message}</p>}
    </div>
    {fetchError && <p>{fetchError.message}</p>}
    <div className="submit-data">
      <form onSubmit={submitItems}>
        <label>
          Name:
          <input type="text" name="name" onChange={(e) => setNewDataItem({...newDataItem, name: e.target.value})} />
        </label>
        <label>
          Age:
          <input type="number" name="age" onChange={(e) => setNewDataItem({...newDataItem, age: Number(e.target.value)})} />
        </label>
        <Button intent="primary" onClick={submitItems}>Submit New Data</Button>
      </form>
      
    </div>
    {dataItems && <div className="view-data">
      <Table>
        <tbody>
      {dataItems.map(item => (
        <tr key={item.id}>
          {showOwnerId && <td>{item.owner_id}</td>}
          <td>{item.name}</td>
          <td>{item.age}</td>
          <td><button onClick={() => deleteItems(item.id)}>Delete</button></td>
        </tr>
      ))}
      </tbody>
      </Table>
    </div>}
    </>
    
   
  )
}

export default SupabaseData

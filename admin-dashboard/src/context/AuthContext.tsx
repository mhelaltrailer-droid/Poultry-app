import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { api } from '../api/client'

type User = {
  id: string
  phone?: string
  name: string
  role?: string
}

type AuthState = {
  token: string | null
  user: User | null
  login: (phone: string, password: string) => Promise<void>
  logout: () => void
  ready: boolean
}

const AuthContext = createContext<AuthState | null>(null)

function loadStoredUser(): User | null {
  try {
    const raw = localStorage.getItem('admin_user')
    return raw ? (JSON.parse(raw) as User) : null
  } catch {
    return null
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<string | null>(() =>
    localStorage.getItem('admin_token')
  )
  const [user, setUser] = useState<User | null>(() => loadStoredUser())
  const [ready, setReady] = useState(false)

  useEffect(() => {
    if (token) {
      localStorage.setItem('admin_token', token)
    } else {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
    }
  }, [token])

  useEffect(() => {
    setReady(true)
  }, [])

  const login = useCallback(async (phone: string, password: string) => {
    const { data } = await api.post<{ token: string; user: User }>(
      '/api/admin/auth/login',
      { phone: phone.replace(/\s/g, ''), password }
    )
    setToken(data.token)
    setUser(data.user)
    localStorage.setItem('admin_user', JSON.stringify(data.user))
  }, [])

  const logout = useCallback(() => {
    setToken(null)
    setUser(null)
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_user')
  }, [])

  const value = useMemo(
    () => ({ token, user, login, logout, ready }),
    [token, user, login, logout, ready]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth outside AuthProvider')
  return ctx
}

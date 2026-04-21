import { useState, type FormEvent } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import styles from './Login.module.css'

export default function Login() {
  const { token, login } = useAuth()
  const [phone, setPhone] = useState('01550490790')
  const [password, setPassword] = useState('0000')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  if (token) return <Navigate to="/" replace />

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      await login(phone.replace(/\s/g, ''), password)
    } catch {
      setError('رقم الهاتف أو كلمة السر غير صحيحة')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className={styles.page}>
      <div className={styles.panel}>
        <div className={styles.brand}>
          <h1 className={styles.title}>DAY TO DAY</h1>
          <p className={styles.tagline}>FRESH EVERYDAY · لوحة التحكم</p>
        </div>
        <form onSubmit={onSubmit} className={styles.form}>
          <label className={styles.field}>
            <span>رقم الهاتف</span>
            <input
              type="tel"
              inputMode="numeric"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required
              autoComplete="username"
            />
          </label>
          <label className={styles.field}>
            <span>كلمة السر</span>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
            />
          </label>
          {error && <p className={styles.error}>{error}</p>}
          <button type="submit" className={styles.submit} disabled={loading}>
            {loading ? 'جاري الدخول…' : 'دخول'}
          </button>
        </form>
      </div>
    </div>
  )
}

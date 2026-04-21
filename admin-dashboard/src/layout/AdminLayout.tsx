import { NavLink, Outlet } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import styles from './AdminLayout.module.css'

const nav = [
  { to: '/', label: 'Overview', end: true },
  { to: '/users', label: 'Users' },
  { to: '/products', label: 'Products' },
  { to: '/orders', label: 'Orders' },
  { to: '/customers', label: 'Customers' },
  { to: '/promotions', label: 'Promotions' },
  { to: '/analytics', label: 'Analytics' },
]

export default function AdminLayout() {
  const { logout, user } = useAuth()

  return (
    <div className={styles.shell}>
      <aside className={styles.sidebar}>
        <div className={styles.brand}>
          <span className={styles.brandTitle}>DAY TO DAY</span>
          <span className={styles.brandTag}>Admin</span>
        </div>
        <nav className={styles.nav}>
          {nav.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `${styles.navLink} ${isActive ? styles.navLinkActive : ''}`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className={styles.footer}>
          <div className={styles.user}>
            {user?.phone ?? user?.name ?? '—'}
          </div>
          <button type="button" className={styles.logout} onClick={logout}>
            Sign out
          </button>
        </div>
      </aside>
      <main className={styles.main}>
        <Outlet />
      </main>
    </div>
  )
}

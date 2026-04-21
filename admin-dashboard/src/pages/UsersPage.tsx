import { useEffect, useState, type FormEvent } from 'react'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type AppUser = {
  _id: string
  phone?: string
  name?: string
  role: string
}

const roleLabels: Record<string, string> = {
  customer: 'عميل',
  app_admin: 'مسؤول التطبيق',
  ops_admin: 'مسؤول إدارة',
  admin: 'مسؤول (قديم)',
}

const roleOptions = ['customer', 'app_admin', 'ops_admin', 'admin'] as const

export default function UsersPage() {
  const [list, setList] = useState<AppUser[]>([])
  const [err, setErr] = useState('')
  const [editing, setEditing] = useState<Partial<AppUser> | null>(null)
  const [password, setPassword] = useState('')

  async function load() {
    const { data } = await api.get<AppUser[]>('/api/admin/users')
    setList(data)
  }

  useEffect(() => {
    load().catch(() => setErr('Failed to load users'))
  }, [])

  function startCreate() {
    setEditing({ name: '', phone: '', role: 'customer' })
    setPassword('')
    setErr('')
  }

  function startEdit(u: AppUser) {
    setEditing({ ...u })
    setPassword('')
    setErr('')
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    if (!editing?.phone || !editing.role) return
    if (!editing._id && !password) {
      setErr('Password required for new user')
      return
    }
    setErr('')
    try {
      if (editing._id) {
        const body: Record<string, unknown> = {
          name: editing.name ?? '',
          phone: editing.phone,
          role: editing.role,
        }
        if (password) body.password = password
        await api.patch(`/api/admin/users/${editing._id}`, body)
      } else {
        await api.post('/api/admin/users', {
          name: editing.name ?? '',
          phone: editing.phone,
          password,
          role: editing.role,
        })
      }
      setEditing(null)
      await load()
    } catch (ex: unknown) {
      const msg =
        (ex as { response?: { data?: { message?: string } } })?.response?.data
          ?.message || 'Save failed'
      setErr(msg)
    }
  }

  async function remove(id: string) {
    if (!confirm('Delete this user?')) return
    await api.delete(`/api/admin/users/${id}`)
    await load()
  }

  return (
    <div>
      <h1 className={u.title}>App users</h1>
      <p className={u.subtitle}>العملاء · مسؤول التطبيق · مسؤول الإدارة</p>
      <button type="button" className={u.btnPrimary} onClick={startCreate}>
        Add user
      </button>
      {err && <p className={u.error}>{err}</p>}

      {editing && (
        <form className={u.card} style={{ marginTop: '1.25rem' }} onSubmit={onSubmit}>
          <h2 style={{ marginTop: 0, fontFamily: 'var(--font-display)' }}>
            {editing._id ? 'Edit user' : 'New user'}
          </h2>
          <div className={u.row}>
            <div className={u.field}>
              <label>Name</label>
              <input
                value={editing.name || ''}
                onChange={(e) =>
                  setEditing({ ...editing, name: e.target.value })
                }
              />
            </div>
            <div className={u.field}>
              <label>Phone</label>
              <input
                value={editing.phone || ''}
                onChange={(e) =>
                  setEditing({ ...editing, phone: e.target.value })
                }
                required
              />
            </div>
            <div className={u.field}>
              <label>Role</label>
              <select
                value={editing.role || 'customer'}
                onChange={(e) =>
                  setEditing({ ...editing, role: e.target.value })
                }
              >
                {roleOptions.map((r) => (
                  <option key={r} value={r}>
                    {roleLabels[r] ?? r}
                  </option>
                ))}
              </select>
            </div>
            <div className={u.field}>
              <label>Password {editing._id ? '(optional)' : ''}</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="new-password"
              />
            </div>
          </div>
          <div className={u.row}>
            <button type="submit" className={u.btnPrimary}>
              Save
            </button>
            <button
              type="button"
              className={u.btnGhost}
              onClick={() => setEditing(null)}
            >
              Cancel
            </button>
          </div>
        </form>
      )}

      <div className={u.card} style={{ marginTop: '1.5rem' }}>
        <div className={u.tableWrap}>
          <table className={u.table}>
            <thead>
              <tr>
                <th>Name</th>
                <th>Phone</th>
                <th>Role</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {list.map((row) => (
                <tr key={row._id}>
                  <td>{row.name || '—'}</td>
                  <td>{row.phone || '—'}</td>
                  <td>{roleLabels[row.role] ?? row.role}</td>
                  <td>
                    <button
                      type="button"
                      className={u.btnGhost}
                      onClick={() => startEdit(row)}
                    >
                      Edit
                    </button>{' '}
                    <button
                      type="button"
                      className={u.btnDanger}
                      onClick={() => remove(row._id)}
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

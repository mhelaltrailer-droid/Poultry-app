import { useEffect, useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type Customer = {
  _id: string
  phone?: string
  name?: string
  district?: string
  addressDetail?: string
  createdAt: string
}

export default function CustomersPage() {
  const [list, setList] = useState<Customer[]>([])
  const [err, setErr] = useState('')
  const [editing, setEditing] = useState<Partial<Customer> | null>(null)
  const [password, setPassword] = useState('')

  async function load() {
    const { data } = await api.get<Customer[]>('/api/admin/customers')
    setList(data)
  }

  useEffect(() => {
    load().catch(() => setErr('Failed to load customers'))
  }, [])

  function startCreate() {
    setEditing({
      name: '',
      phone: '',
      district: '',
      addressDetail: '',
    })
    setPassword('')
    setErr('')
  }

  function startEdit(c: Customer) {
    setEditing({ ...c })
    setPassword('')
    setErr('')
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    if (!editing?.phone) return
    if (!editing._id && !password) {
      setErr('Password required for new customer')
      return
    }
    setErr('')
    try {
      if (editing._id) {
        const body: Record<string, unknown> = {
          name: editing.name ?? '',
          phone: editing.phone,
          district: editing.district ?? '',
          addressDetail: editing.addressDetail ?? '',
        }
        if (password) body.password = password
        await api.patch(`/api/admin/customers/${editing._id}`, body)
      } else {
        await api.post('/api/admin/customers', {
          name: editing.name ?? '',
          phone: editing.phone,
          password,
          district: editing.district ?? '',
          addressDetail: editing.addressDetail ?? '',
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
    if (!confirm('Delete this customer?')) return
    await api.delete(`/api/admin/customers/${id}`)
    await load()
  }

  return (
    <div>
      <h1 className={u.title}>Customers</h1>
      <p className={u.subtitle}>الاسم · الهاتف · الحي · العنوان التفصيلي</p>
      <button type="button" className={u.btnPrimary} onClick={startCreate}>
        Add customer
      </button>
      {err && <p className={u.error}>{err}</p>}

      {editing && (
        <form className={u.card} style={{ marginTop: '1.25rem' }} onSubmit={onSubmit}>
          <h2 style={{ marginTop: 0, fontFamily: 'var(--font-display)' }}>
            {editing._id ? 'Edit customer' : 'New customer'}
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
              <label>District (الحي)</label>
              <input
                value={editing.district || ''}
                onChange={(e) =>
                  setEditing({ ...editing, district: e.target.value })
                }
              />
            </div>
            <div className={u.field} style={{ minWidth: '220px' }}>
              <label>Address detail</label>
              <textarea
                rows={2}
                value={editing.addressDetail || ''}
                onChange={(e) =>
                  setEditing({ ...editing, addressDetail: e.target.value })
                }
              />
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
                <th>Phone</th>
                <th>Name</th>
                <th>District</th>
                <th>Joined</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {list.map((c) => (
                <tr key={c._id}>
                  <td>{c.phone || '—'}</td>
                  <td>{c.name || '—'}</td>
                  <td>{c.district || '—'}</td>
                  <td>{new Date(c.createdAt).toLocaleDateString()}</td>
                  <td>
                    <button
                      type="button"
                      className={u.btnGhost}
                      onClick={() => startEdit(c)}
                    >
                      Edit
                    </button>{' '}
                    <button
                      type="button"
                      className={u.btnDanger}
                      onClick={() => remove(c._id)}
                    >
                      Delete
                    </button>{' '}
                    <Link to={`/customers/${c._id}`}>Orders</Link>
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

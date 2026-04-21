import { useEffect, useState, type FormEvent } from 'react'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type Promotion = {
  _id: string
  code: string
  discountType: 'percent' | 'fixed'
  discountValue: number
  minOrderAmount: number
  maxDiscount?: number | null
  expiresAt?: string | null
  isActive: boolean
  usageLimit?: number | null
  usageCount: number
}

export default function PromotionsPage() {
  const [list, setList] = useState<Promotion[]>([])
  const [form, setForm] = useState({
    code: '',
    discountType: 'percent' as 'percent' | 'fixed',
    discountValue: 10,
    minOrderAmount: 0,
    maxDiscount: '' as string | number,
    expiresAt: '',
    usageLimit: '' as string | number,
  })
  const [err, setErr] = useState('')

  async function load() {
    const { data } = await api.get<Promotion[]>('/api/admin/promotions')
    setList(data)
  }

  useEffect(() => {
    load().catch(() => setErr('Failed to load promotions'))
  }, [])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setErr('')
    try {
      await api.post('/api/admin/promotions', {
        code: form.code,
        discountType: form.discountType,
        discountValue: form.discountValue,
        minOrderAmount: form.minOrderAmount,
        maxDiscount: form.maxDiscount === '' ? null : Number(form.maxDiscount),
        expiresAt: form.expiresAt
          ? new Date(form.expiresAt).toISOString()
          : null,
        usageLimit: form.usageLimit === '' ? null : Number(form.usageLimit),
      })
      setForm({
        code: '',
        discountType: 'percent',
        discountValue: 10,
        minOrderAmount: 0,
        maxDiscount: '',
        expiresAt: '',
        usageLimit: '',
      })
      await load()
    } catch (ex: unknown) {
      const msg =
        (ex as { response?: { data?: { message?: string } } })?.response?.data
          ?.message || 'Create failed'
      setErr(msg)
    }
  }

  async function toggle(id: string, isActive: boolean) {
    await api.patch(`/api/admin/promotions/${id}`, { isActive: !isActive })
    await load()
  }

  async function remove(id: string) {
    if (!confirm('Delete promo code?')) return
    await api.delete(`/api/admin/promotions/${id}`)
    await load()
  }

  return (
    <div>
      <h1 className={u.title}>Promotions</h1>
      <p className={u.subtitle}>Promo codes and discounts</p>
      {err && <p className={u.error}>{err}</p>}

      <form className={u.card} onSubmit={onSubmit}>
        <h2 style={{ marginTop: 0, fontFamily: 'var(--font-display)' }}>
          New promo code
        </h2>
        <div className={u.row}>
          <div className={u.field}>
            <label>Code</label>
            <input
              value={form.code}
              onChange={(e) =>
                setForm({ ...form, code: e.target.value.toUpperCase() })
              }
              required
            />
          </div>
          <div className={u.field}>
            <label>Type</label>
            <select
              value={form.discountType}
              onChange={(e) =>
                setForm({
                  ...form,
                  discountType: e.target.value as 'percent' | 'fixed',
                })
              }
            >
              <option value="percent">Percent</option>
              <option value="fixed">Fixed amount</option>
            </select>
          </div>
          <div className={u.field}>
            <label>Value</label>
            <input
              type="number"
              step="0.01"
              min={0}
              value={form.discountValue}
              onChange={(e) =>
                setForm({ ...form, discountValue: Number(e.target.value) })
              }
              required
            />
          </div>
          <div className={u.field}>
            <label>Min order</label>
            <input
              type="number"
              step="0.01"
              min={0}
              value={form.minOrderAmount}
              onChange={(e) =>
                setForm({ ...form, minOrderAmount: Number(e.target.value) })
              }
            />
          </div>
          <div className={u.field}>
            <label>Max discount (optional)</label>
            <input
              type="number"
              step="0.01"
              min={0}
              value={form.maxDiscount}
              onChange={(e) =>
                setForm({ ...form, maxDiscount: e.target.value })
              }
            />
          </div>
          <div className={u.field}>
            <label>Expires (ISO date)</label>
            <input
              type="datetime-local"
              value={form.expiresAt}
              onChange={(e) =>
                setForm({ ...form, expiresAt: e.target.value })
              }
            />
          </div>
          <div className={u.field}>
            <label>Usage limit</label>
            <input
              type="number"
              min={1}
              value={form.usageLimit}
              onChange={(e) =>
                setForm({ ...form, usageLimit: e.target.value })
              }
            />
          </div>
        </div>
        <button type="submit" className={u.btnPrimary}>
          Create
        </button>
      </form>

      <div className={u.card} style={{ marginTop: '1.5rem' }}>
        <div className={u.tableWrap}>
          <table className={u.table}>
            <thead>
              <tr>
                <th>Code</th>
                <th>Discount</th>
                <th>Uses</th>
                <th>Active</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {list.map((p) => (
                <tr key={p._id}>
                  <td>{p.code}</td>
                  <td>
                    {p.discountType === 'percent'
                      ? `${p.discountValue}%`
                      : p.discountValue}
                  </td>
                  <td>
                    {p.usageCount}
                    {p.usageLimit != null ? ` / ${p.usageLimit}` : ''}
                  </td>
                  <td>{p.isActive ? 'Yes' : 'No'}</td>
                  <td>
                    <button
                      type="button"
                      className={u.btnGhost}
                      onClick={() => toggle(p._id, p.isActive)}
                    >
                      Toggle
                    </button>{' '}
                    <button
                      type="button"
                      className={u.btnDanger}
                      onClick={() => remove(p._id)}
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

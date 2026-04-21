import { useEffect, useState } from 'react'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type PopulatedUser = { _id: string; phone?: string; name?: string }

type Order = {
  _id: string
  orderNumber: string
  status: string
  total: number
  assignedDelivery?: string
  customerId?: PopulatedUser
  createdAt: string
}

const STATUSES = [
  'pending',
  'preparing',
  'on_the_way',
  'delivered',
  'cancelled',
] as const

const labels: Record<string, string> = {
  pending: 'Pending',
  preparing: 'Preparing',
  on_the_way: 'On the way',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
}

export default function OrdersPage() {
  const [list, setList] = useState<Order[]>([])
  const [filter, setFilter] = useState('')
  const [deliveryId, setDeliveryId] = useState<string | null>(null)
  const [deliveryName, setDeliveryName] = useState('')
  const [err, setErr] = useState('')

  async function load() {
    const q = filter ? `?status=${filter}` : ''
    const { data } = await api.get<Order[]>(`/api/admin/orders${q}`)
    setList(data)
  }

  useEffect(() => {
    load().catch(() => setErr('Failed to load orders'))
  }, [filter])

  async function updateStatus(id: string, status: string) {
    setErr('')
    try {
      await api.patch(`/api/admin/orders/${id}/status`, { status })
      await load()
    } catch {
      setErr('Status update failed')
    }
  }

  async function assignDelivery() {
    if (!deliveryId) return
    setErr('')
    try {
      await api.patch(`/api/admin/orders/${deliveryId}/delivery`, {
        assignedDelivery: deliveryName,
      })
      setDeliveryId(null)
      setDeliveryName('')
      await load()
    } catch {
      setErr('Assign delivery failed')
    }
  }

  return (
    <div>
      <h1 className={u.title}>Orders</h1>
      <p className={u.subtitle}>Update status and assign delivery</p>
      <div className={u.row}>
        <div className={u.field}>
          <label>Filter status</label>
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
          >
            <option value="">All</option>
            {STATUSES.map((s) => (
              <option key={s} value={s}>
                {labels[s]}
              </option>
            ))}
          </select>
        </div>
      </div>
      {err && <p className={u.error}>{err}</p>}

      {deliveryId && (
        <div className={u.card} style={{ marginBottom: '1rem' }}>
          <strong>Assign delivery</strong>
          <div className={u.row} style={{ marginTop: '0.75rem' }}>
            <input
              className={u.field}
              placeholder="Driver name / phone"
              value={deliveryName}
              onChange={(e) => setDeliveryName(e.target.value)}
              style={{ padding: '0.5rem', minWidth: '240px' }}
            />
            <button type="button" className={u.btnPrimary} onClick={assignDelivery}>
              Save
            </button>
            <button
              type="button"
              className={u.btnGhost}
              onClick={() => setDeliveryId(null)}
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      <div className={u.card}>
        <div className={u.tableWrap}>
          <table className={u.table}>
            <thead>
              <tr>
                <th>Order</th>
                <th>Customer</th>
                <th>Total</th>
                <th>Status</th>
                <th>Delivery</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              {list.map((o) => (
                <tr key={o._id}>
                  <td>{o.orderNumber}</td>
                  <td>
                    {typeof o.customerId === 'object' && o.customerId
                      ? o.customerId.phone || o.customerId.name || '—'
                      : '—'}
                  </td>
                  <td>{o.total.toFixed(2)}</td>
                  <td>
                    <select
                      value={o.status}
                      onChange={(e) => updateStatus(o._id, e.target.value)}
                    >
                      {STATUSES.map((s) => (
                        <option key={s} value={s}>
                          {labels[s]}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td>
                    {o.assignedDelivery || '—'}
                    <button
                      type="button"
                      className={u.btnGhost}
                      style={{ marginLeft: '0.5rem', padding: '0.25rem 0.5rem' }}
                      onClick={() => {
                        setDeliveryId(o._id)
                        setDeliveryName(o.assignedDelivery || '')
                      }}
                    >
                      Assign
                    </button>
                  </td>
                  <td>{new Date(o.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

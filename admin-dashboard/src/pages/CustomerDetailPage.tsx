import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type OrderRow = {
  orderNumber: string
  status: string
  total: number
  createdAt: string
}

type Detail = {
  _id: string
  phone?: string
  name?: string
  district?: string
  addressDetail?: string
  addresses?: unknown[]
  orders: OrderRow[]
}

const labels: Record<string, string> = {
  pending: 'Pending',
  preparing: 'Preparing',
  on_the_way: 'On the way',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
}

export default function CustomerDetailPage() {
  const { id } = useParams<{ id: string }>()
  const [data, setData] = useState<Detail | null>(null)
  const [err, setErr] = useState('')

  useEffect(() => {
    if (!id) return
    api
      .get<Detail>(`/api/admin/customers/${id}`)
      .then((r) => setData(r.data))
      .catch(() => setErr('Customer not found'))
  }, [id])

  if (err) return <p className={u.error}>{err}</p>
  if (!data) return <p>Loading…</p>

  return (
    <div>
      <Link to="/customers">← Customers</Link>
      <h1 className={u.title} style={{ marginTop: '1rem' }}>
        {data.name || data.phone || 'Customer'}
      </h1>
      <p className={u.subtitle}>
        {data.phone}
        {data.district ? ` · الحي: ${data.district}` : ''}
        {data.addressDetail ? ` · ${data.addressDetail}` : ''}
      </p>
      <div className={u.card}>
        <h2 style={{ marginTop: 0, fontFamily: 'var(--font-display)' }}>
          Order history
        </h2>
        <div className={u.tableWrap}>
          <table className={u.table}>
            <thead>
              <tr>
                <th>Order</th>
                <th>Status</th>
                <th>Total</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {data.orders.map((o) => (
                <tr key={o.orderNumber}>
                  <td>{o.orderNumber}</td>
                  <td>
                    <span className={u.badge}>
                      {labels[o.status] ?? o.status}
                    </span>
                  </td>
                  <td>{o.total.toFixed(2)}</td>
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

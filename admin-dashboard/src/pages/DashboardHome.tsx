import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type Summary = {
  totalRevenue: number
  ordersByStatus: Record<string, number>
  recentOrders: { orderNumber: string; status: string; total: number; createdAt: string }[]
}

export default function DashboardHome() {
  const [data, setData] = useState<Summary | null>(null)
  const [err, setErr] = useState('')

  useEffect(() => {
    api
      .get<Summary>('/api/admin/analytics/summary')
      .then((r) => setData(r.data))
      .catch(() => setErr('Could not load analytics'))
  }, [])

  const statusLabels: Record<string, string> = {
    pending: 'Pending',
    preparing: 'Preparing',
    on_the_way: 'On the way',
    delivered: 'Delivered',
    cancelled: 'Cancelled',
  }

  return (
    <div>
      <h1 className={u.title}>Overview</h1>
      <p className={u.subtitle}>DAY TO DAY operations at a glance</p>
      {err && <p className={u.error}>{err}</p>}
      {data && (
        <>
          <div className={u.gridStats}>
            <div className={u.stat}>
              <div className={u.statValue}>
                {data.totalRevenue.toFixed(2)}
              </div>
              <div className={u.statLabel}>Total revenue</div>
            </div>
            {Object.entries(data.ordersByStatus).map(([k, v]) => (
              <div key={k} className={u.stat}>
                <div className={u.statValue}>{v}</div>
                <div className={u.statLabel}>
                  {statusLabels[k] ?? k} orders
                </div>
              </div>
            ))}
          </div>
          <div className={u.card}>
            <h2 className={u.title} style={{ fontSize: '1.15rem' }}>
              Recent orders
            </h2>
            <div className={u.tableWrap}>
              <table className={u.table}>
                <thead>
                  <tr>
                    <th>Order</th>
                    <th>Status</th>
                    <th>Total</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {data.recentOrders.map((o) => (
                    <tr key={o.orderNumber}>
                      <td>{o.orderNumber}</td>
                      <td>
                        <span className={u.badge}>
                          {statusLabels[o.status] ?? o.status}
                        </span>
                      </td>
                      <td>{o.total.toFixed(2)}</td>
                      <td>
                        <Link to="/orders">Manage</Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  )
}

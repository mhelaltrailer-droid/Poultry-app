import { useEffect, useState } from 'react'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type Summary = {
  totalRevenue: number
  ordersByStatus: Record<string, number>
  recentOrders: { orderNumber: string; status: string; total: number; createdAt: string }[]
}

export default function AnalyticsPage() {
  const [data, setData] = useState<Summary | null>(null)

  useEffect(() => {
    api.get<Summary>('/api/admin/analytics/summary').then((r) => setData(r.data))
  }, [])

  if (!data) return <p>Loading…</p>

  return (
    <div>
      <h1 className={u.title}>Analytics</h1>
      <p className={u.subtitle}>Sales overview and order distribution</p>
      <div className={u.gridStats}>
        <div className={u.stat}>
          <div className={u.statValue}>{data.totalRevenue.toFixed(2)}</div>
          <div className={u.statLabel}>Lifetime revenue (excl. cancelled)</div>
        </div>
        {Object.entries(data.ordersByStatus).map(([k, v]) => (
          <div key={k} className={u.stat}>
            <div className={u.statValue}>{v}</div>
            <div className={u.statLabel}>{k.replace(/_/g, ' ')}</div>
          </div>
        ))}
      </div>
      <div className={u.card}>
        <h2 style={{ marginTop: 0 }}>Recent activity</h2>
        <div className={u.tableWrap}>
          <table className={u.table}>
            <thead>
              <tr>
                <th>Order</th>
                <th>Status</th>
                <th>Total</th>
                <th>Time</th>
              </tr>
            </thead>
            <tbody>
              {data.recentOrders.map((o) => (
                <tr key={o.orderNumber + o.createdAt}>
                  <td>{o.orderNumber}</td>
                  <td>{o.status}</td>
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

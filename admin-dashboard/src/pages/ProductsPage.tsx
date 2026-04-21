import { useEffect, useState, type FormEvent } from 'react'
import { api } from '../api/client'
import u from '../ui/page.module.css'

type Product = {
  _id: string
  name: string
  slug: string
  description: string
  images: string[]
  price: number
  salePrice?: number | null
  weightValue: number
  weightUnit: string
  stock: number
  maxOrderQty?: number
  category: string
  isActive: boolean
}

const empty: Partial<Product> = {
  name: '',
  description: '',
  images: [],
  price: 0,
  salePrice: null,
  weightValue: 1,
  weightUnit: 'kg',
  stock: 0,
  maxOrderQty: 50,
  category: 'poultry',
  isActive: true,
}

export default function ProductsPage() {
  const [list, setList] = useState<Product[]>([])
  const [editing, setEditing] = useState<Partial<Product> | null>(null)
  const [imageUrl, setImageUrl] = useState('')
  const [uploading, setUploading] = useState(false)
  const [err, setErr] = useState('')

  async function load() {
    const { data } = await api.get<Product[]>('/api/admin/products')
    setList(data)
  }

  useEffect(() => {
    load().catch(() => setErr('Failed to load products'))
  }, [])

  function startCreate() {
    setEditing({ ...empty })
    setImageUrl('')
    setErr('')
  }

  function startEdit(p: Product) {
    setEditing({ ...p })
    setImageUrl('')
    setErr('')
  }

  async function onUpload(file: File) {
    setUploading(true)
    setErr('')
    try {
      const fd = new FormData()
      fd.append('file', file)
      const { data } = await api.post<{ url: string }>('/api/admin/upload', fd, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      setEditing((e) => {
        const imgs = [...(e?.images || []), data.url]
        return { ...(e || {}), images: imgs }
      })
    } catch {
      setErr('Upload failed — check Cloudinary configuration on API')
    } finally {
      setUploading(false)
    }
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    if (!editing?.name) return
    setErr('')
    try {
      if (editing._id) {
        await api.patch(`/api/admin/products/${editing._id}`, editing)
      } else {
        await api.post('/api/admin/products', editing)
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
    if (!confirm('Delete this product?')) return
    await api.delete(`/api/admin/products/${id}`)
    await load()
  }

  return (
    <div>
      <h1 className={u.title}>Products</h1>
      <p className={u.subtitle}>Manage catalogue, pricing, and weights</p>
      <button type="button" className={u.btnPrimary} onClick={startCreate}>
        Add product
      </button>
      {err && <p className={u.error}>{err}</p>}

      {editing && (
        <form className={u.card} style={{ marginTop: '1.25rem' }} onSubmit={onSubmit}>
          <h2 style={{ marginTop: 0, fontFamily: 'var(--font-display)' }}>
            {editing._id ? 'Edit product' : 'New product'}
          </h2>
          <div className={u.row}>
            <div className={u.field}>
              <label>Name</label>
              <input
                value={editing.name || ''}
                onChange={(e) =>
                  setEditing({ ...editing, name: e.target.value })
                }
                required
              />
            </div>
            <div className={u.field}>
              <label>Price</label>
              <input
                type="number"
                step="0.01"
                min={0}
                value={editing.price ?? 0}
                onChange={(e) =>
                  setEditing({ ...editing, price: Number(e.target.value) })
                }
                required
              />
            </div>
            <div className={u.field}>
              <label>Sale price (optional)</label>
              <input
                type="number"
                step="0.01"
                min={0}
                value={
                  editing.salePrice === null || editing.salePrice === undefined
                    ? ''
                    : editing.salePrice
                }
                onChange={(e) => {
                  const v = e.target.value
                  setEditing({
                    ...editing,
                    salePrice: v === '' ? null : Number(v),
                  })
                }}
              />
            </div>
            <div className={u.field}>
              <label>Weight value</label>
              <input
                type="number"
                step="0.01"
                min={0}
                value={editing.weightValue ?? 0}
                onChange={(e) =>
                  setEditing({ ...editing, weightValue: Number(e.target.value) })
                }
                required
              />
            </div>
            <div className={u.field}>
              <label>Unit</label>
              <select
                value={editing.weightUnit || 'kg'}
                onChange={(e) =>
                  setEditing({ ...editing, weightUnit: e.target.value })
                }
              >
                <option value="g">g</option>
                <option value="kg">kg</option>
                <option value="lb">lb</option>
                <option value="piece">piece</option>
              </select>
            </div>
            <div className={u.field}>
              <label>Stock</label>
              <input
                type="number"
                min={0}
                value={editing.stock ?? 0}
                onChange={(e) =>
                  setEditing({ ...editing, stock: Number(e.target.value) })
                }
              />
            </div>
            <div className={u.field}>
              <label>Max per order</label>
              <input
                type="number"
                min={1}
                value={editing.maxOrderQty ?? 50}
                onChange={(e) =>
                  setEditing({
                    ...editing,
                    maxOrderQty: Number(e.target.value),
                  })
                }
              />
            </div>
            <div className={u.field}>
              <label>Category</label>
              <input
                value={editing.category || ''}
                onChange={(e) =>
                  setEditing({ ...editing, category: e.target.value })
                }
              />
            </div>
            <div className={u.field}>
              <label>Active</label>
              <select
                value={editing.isActive ? 'yes' : 'no'}
                onChange={(e) =>
                  setEditing({ ...editing, isActive: e.target.value === 'yes' })
                }
              >
                <option value="yes">Yes</option>
                <option value="no">No</option>
              </select>
            </div>
          </div>
          <div className={u.field} style={{ maxWidth: '100%' }}>
            <label>Description</label>
            <textarea
              rows={3}
              value={editing.description || ''}
              onChange={(e) =>
                setEditing({ ...editing, description: e.target.value })
              }
            />
          </div>
          <div className={u.row}>
            <div className={u.field}>
              <label>Image URL (optional)</label>
              <input
                value={imageUrl}
                onChange={(e) => setImageUrl(e.target.value)}
                placeholder="https://..."
              />
            </div>
            <button
              type="button"
              className={u.btnGhost}
              onClick={() => {
                if (!imageUrl.trim()) return
                setEditing((e) => ({
                  ...(e || {}),
                  images: [...(e?.images || []), imageUrl.trim()],
                }))
                setImageUrl('')
              }}
            >
              Add URL
            </button>
            <label className={u.btnGhost} style={{ cursor: 'pointer' }}>
              {uploading ? 'Uploading…' : 'Upload file'}
              <input
                type="file"
                accept="image/*"
                hidden
                onChange={(e) => {
                  const f = e.target.files?.[0]
                  if (f) onUpload(f)
                  e.target.value = ''
                }}
              />
            </label>
          </div>
          {(editing.images?.length ?? 0) > 0 && (
            <p style={{ fontSize: '0.8rem' }}>
              Images: {editing.images?.join(', ')}
            </p>
          )}
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
                <th>Price</th>
                <th>Sale</th>
                <th>Max/qty</th>
                <th>Weight</th>
                <th>Stock</th>
                <th>Active</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {list.map((p) => (
                <tr key={p._id}>
                  <td>{p.name}</td>
                  <td>{p.price.toFixed(2)}</td>
                  <td>
                    {p.salePrice != null ? Number(p.salePrice).toFixed(2) : '—'}
                  </td>
                  <td>{p.maxOrderQty ?? 50}</td>
                  <td>
                    {p.weightValue}
                    {p.weightUnit}
                  </td>
                  <td>{p.stock}</td>
                  <td>{p.isActive ? 'Yes' : 'No'}</td>
                  <td>
                    <button
                      type="button"
                      className={u.btnGhost}
                      onClick={() => startEdit(p)}
                    >
                      Edit
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

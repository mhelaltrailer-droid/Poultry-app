import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes.js';
import adminAuthRoutes from './routes/adminAuth.routes.js';
import productRoutes from './routes/product.routes.js';
import meRoutes from './routes/me.routes.js';
import orderRoutes from './routes/order.routes.js';
import productsAdmin from './routes/admin/products.admin.routes.js';
import ordersAdmin from './routes/admin/orders.admin.routes.js';
import customersAdmin from './routes/admin/customers.admin.routes.js';
import promotionsAdmin from './routes/admin/promotions.admin.routes.js';
import analyticsAdmin from './routes/admin/analytics.admin.routes.js';
import uploadAdmin from './routes/admin/upload.admin.routes.js';
import usersAdmin from './routes/admin/users.admin.routes.js';
import flashOffersAdmin from './routes/admin/flashOffers.admin.routes.js';
import flashOfferRoutes from './routes/flashOffer.routes.js';
import districtRoutes from './routes/district.routes.js';
import districtsAdmin from './routes/admin/districts.admin.routes.js';
import { authenticate, requireAdmin } from './middleware/auth.js';
import { errorHandler } from './middleware/errorHandler.js';

const app = express();

// Chrome: طلبات من localhost (Flutter web) إلى 127.0.0.1 تتطلب هذا الرأس
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Private-Network', 'true');
  next();
});

const allowedOrigins = (process.env.CORS_ORIGIN ?? '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

app.use(
  cors({
    origin(origin, callback) {
      if (!origin) return callback(null, true);
      if (allowedOrigins.length === 0) {
        return callback(null, true);
      }
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      callback(null, false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Access-Control-Request-Private-Network',
    ],
  })
);
app.use(express.json({ limit: '2mb' }));

app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'day-to-day-api' });
});

app.use('/api/auth', authRoutes);
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/products', productRoutes);
app.use('/api/me', meRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/flash-offers', flashOfferRoutes);
app.use('/api/districts', districtRoutes);

app.use('/api/admin', authenticate, requireAdmin);
app.use('/api/admin/users', usersAdmin);
app.use('/api/admin/products', productsAdmin);
app.use('/api/admin/orders', ordersAdmin);
app.use('/api/admin/customers', customersAdmin);
app.use('/api/admin/promotions', promotionsAdmin);
app.use('/api/admin/analytics', analyticsAdmin);
app.use('/api/admin/upload', uploadAdmin);
app.use('/api/admin/flash-offers', flashOffersAdmin);
app.use('/api/admin/districts', districtsAdmin);

app.use(errorHandler);

export default app;

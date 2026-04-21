import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import mongoose from 'mongoose';
import { Order } from '../models/Order.js';
import { authenticate, requireCustomer } from '../middleware/auth.js';
import {
  placeOrder,
  placeOrderInTransaction,
} from '../services/orderPlacement.service.js';

const router = Router();

function isTransactionNotSupported(error) {
  const msg = String(error?.message || error).toLowerCase();
  return (
    msg.includes('transaction numbers are only allowed') ||
    msg.includes('replica set member') ||
    msg.includes('mongos')
  );
}

const itemsRule = [
  body('items').isArray({ min: 1 }),
  body('items.*.productId').isMongoId(),
  body('items.*.quantity').isInt({ min: 1 }),
  body('deliveryAddress.line1').notEmpty(),
  body('deliveryAddress.city').notEmpty(),
  body('deliveryAddress.phone').notEmpty(),
  body('deliveryFee').optional().isFloat({ min: 0 }),
  body('promoCode').optional().isString(),
  body('notes').optional().isString(),
  body('locale').optional().isIn(['en', 'ar']),
];

router.post(
  '/guest',
  ...itemsRule,
  body('guestName').trim().notEmpty().withMessage('Name required'),
  body('guestPhone').trim().notEmpty().isLength({ min: 8, max: 24 }),
  async (req, res, next) => {
    const session = await mongoose.startSession();
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      session.startTransaction();
      const { items, deliveryAddress, deliveryFee = 0, promoCode, notes } =
        req.body;
      let order;
      try {
        order = await placeOrderInTransaction({
          session,
          customerId: null,
          guestName: req.body.guestName,
          guestPhone: req.body.guestPhone,
          items,
          deliveryAddress,
          deliveryFee,
          promoCode,
          notes,
          locale: req.body.locale === 'ar' ? 'ar' : 'en',
        });
        await session.commitTransaction();
      } catch (e) {
        if (!isTransactionNotSupported(e)) throw e;
        await session.abortTransaction();
        order = await placeOrder({
          customerId: null,
          guestName: req.body.guestName,
          guestPhone: req.body.guestPhone,
          items,
          deliveryAddress,
          deliveryFee,
          promoCode,
          notes,
          locale: req.body.locale === 'ar' ? 'ar' : 'en',
        });
      }
      res.status(201).json(order);
    } catch (e) {
      try {
        await session.abortTransaction();
      } catch (_) {}
      next(e);
    } finally {
      session.endSession();
    }
  }
);

router.get('/guest/by-phone/:phone', async (req, res, next) => {
  try {
    const phone = (req.params.phone ?? '').toString().trim();
    if (!phone) return res.status(400).json({ message: 'Phone required' });
    const orders = await Order.find({ guestPhone: phone })
      .sort({ createdAt: -1 })
      .lean();
    res.json(orders);
  } catch (e) {
    next(e);
  }
});

router.use(authenticate, requireCustomer);

router.post(
  '/',
  ...itemsRule,
  async (req, res, next) => {
    const session = await mongoose.startSession();
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      session.startTransaction();
      const { items, deliveryAddress, deliveryFee = 0, promoCode, notes } =
        req.body;
      let order;
      try {
        order = await placeOrderInTransaction({
          session,
          customerId: req.user.id,
          items,
          deliveryAddress,
          deliveryFee,
          promoCode,
          notes,
          locale: req.body.locale === 'ar' ? 'ar' : 'en',
        });
        await session.commitTransaction();
      } catch (e) {
        if (!isTransactionNotSupported(e)) throw e;
        await session.abortTransaction();
        order = await placeOrder({
          customerId: req.user.id,
          items,
          deliveryAddress,
          deliveryFee,
          promoCode,
          notes,
          locale: req.body.locale === 'ar' ? 'ar' : 'en',
        });
      }
      res.status(201).json(order);
    } catch (e) {
      try {
        await session.abortTransaction();
      } catch (_) {}
      next(e);
    } finally {
      session.endSession();
    }
  }
);

router.get('/', async (req, res, next) => {
  try {
    const orders = await Order.find({ customerId: req.user.id })
      .sort({ createdAt: -1 })
      .lean();
    res.json(orders);
  } catch (e) {
    next(e);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      customerId: req.user.id,
    }).lean();
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (e) {
    next(e);
  }
});

export default router;

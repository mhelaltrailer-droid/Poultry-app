import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { Promotion } from '../../models/Promotion.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const list = await Promotion.find().sort({ createdAt: -1 }).lean();
    res.json(list);
  } catch (e) {
    next(e);
  }
});

router.post(
  '/',
  body('code').trim().notEmpty(),
  body('discountType').isIn(['percent', 'fixed']),
  body('discountValue').isFloat({ min: 0 }),
  body('minOrderAmount').optional().isFloat({ min: 0 }),
  body('maxDiscount').optional().isFloat({ min: 0 }),
  body('expiresAt').optional().isISO8601(),
  body('isActive').optional().isBoolean(),
  body('usageLimit').optional().isInt({ min: 1 }),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const p = await Promotion.create({
        code: req.body.code.toUpperCase(),
        discountType: req.body.discountType,
        discountValue: req.body.discountValue,
        minOrderAmount: req.body.minOrderAmount ?? 0,
        maxDiscount: req.body.maxDiscount ?? null,
        expiresAt: req.body.expiresAt ? new Date(req.body.expiresAt) : null,
        isActive: req.body.isActive ?? true,
        usageLimit: req.body.usageLimit ?? null,
      });
      res.status(201).json(p);
    } catch (e) {
      if (e.code === 11000) {
        return res.status(400).json({ message: 'Promo code already exists' });
      }
      next(e);
    }
  }
);

router.patch(
  '/:id',
  body('discountType').optional().isIn(['percent', 'fixed']),
  body('discountValue').optional().isFloat({ min: 0 }),
  body('minOrderAmount').optional().isFloat({ min: 0 }),
  body('maxDiscount').optional().isFloat({ min: 0 }),
  body('expiresAt').optional().isISO8601(),
  body('isActive').optional().isBoolean(),
  body('usageLimit').optional().isInt({ min: 1 }),
  async (req, res, next) => {
    try {
      const promo = await Promotion.findById(req.params.id);
      if (!promo) return res.status(404).json({ message: 'Not found' });
      const u = req.body;
      if (u.discountType != null) promo.discountType = u.discountType;
      if (u.discountValue != null) promo.discountValue = u.discountValue;
      if (u.minOrderAmount != null) promo.minOrderAmount = u.minOrderAmount;
      if (u.maxDiscount !== undefined) promo.maxDiscount = u.maxDiscount;
      if (u.expiresAt !== undefined) {
        promo.expiresAt = u.expiresAt ? new Date(u.expiresAt) : null;
      }
      if (u.isActive != null) promo.isActive = u.isActive;
      if (u.usageLimit !== undefined) promo.usageLimit = u.usageLimit;
      await promo.save();
      res.json(promo);
    } catch (e) {
      next(e);
    }
  }
);

router.delete('/:id', async (req, res, next) => {
  try {
    await Promotion.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;

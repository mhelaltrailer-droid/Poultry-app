import mongoose from 'mongoose';
import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { FlashOffer } from '../../models/FlashOffer.js';

const router = Router();

function parseDateOrNull(v) {
  if (v == null || v === '') return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

function withComputedState(offer) {
  const now = new Date();
  const remaining = Math.max(0, (offer.totalAvailable ?? 0) - (offer.totalUsed ?? 0));
  const isWithinTime =
    offer.startsAt != null &&
    offer.endsAt != null &&
    new Date(offer.startsAt) <= now &&
    new Date(offer.endsAt) >= now;
  const isLive = Boolean(offer.isEnabled) && isWithinTime && remaining > 0;
  return { ...offer, remainingCount: remaining, isLive };
}

const createValidators = [
  body('title').trim().notEmpty(),
  body('imageUrl').optional().isString(),
  body('productIds').isArray({ min: 1 }),
  body('productIds.*').custom((id) => mongoose.Types.ObjectId.isValid(id)),
  body('originalPrice').isFloat({ min: 0 }),
  body('discountedPrice').isFloat({ min: 0 }),
  body('startsAt').isISO8601(),
  body('endsAt').isISO8601(),
  body('maxQtyPerOrder').isInt({ min: 1 }),
  body('totalAvailable').isInt({ min: 1 }),
  body('totalUsed').optional().isInt({ min: 0 }),
  body('isEnabled').optional().isBoolean(),
];

const updateValidators = [
  body('title').optional().trim().notEmpty(),
  body('imageUrl').optional().isString(),
  body('productIds').optional().isArray({ min: 1 }),
  body('productIds.*').optional().custom((id) => mongoose.Types.ObjectId.isValid(id)),
  body('originalPrice').optional().isFloat({ min: 0 }),
  body('discountedPrice').optional().isFloat({ min: 0 }),
  body('startsAt').optional().isISO8601(),
  body('endsAt').optional().isISO8601(),
  body('maxQtyPerOrder').optional().isInt({ min: 1 }),
  body('totalAvailable').optional().isInt({ min: 1 }),
  body('totalUsed').optional().isInt({ min: 0 }),
  body('isEnabled').optional().isBoolean(),
];

router.get('/', async (req, res, next) => {
  try {
    const list = await FlashOffer.find()
      .sort({ createdAt: -1 })
      .populate('productIds', 'name nameEn nameAr images price salePrice isActive')
      .lean();
    res.json(list.map(withComputedState));
  } catch (e) {
    next(e);
  }
});

router.post('/', createValidators, async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: errors.array()[0].msg });
    }
    const startsAt = parseDateOrNull(req.body.startsAt);
    const endsAt = parseDateOrNull(req.body.endsAt);
    if (startsAt == null || endsAt == null || startsAt >= endsAt) {
      return res.status(400).json({ message: 'Invalid offer start/end time' });
    }
    if (Number(req.body.discountedPrice) > Number(req.body.originalPrice)) {
      return res.status(400).json({ message: 'Discounted price must be <= original price' });
    }
    const offer = await FlashOffer.create({
      title: req.body.title,
      imageUrl: req.body.imageUrl ?? '',
      productIds: req.body.productIds,
      originalPrice: Number(req.body.originalPrice),
      discountedPrice: Number(req.body.discountedPrice),
      startsAt,
      endsAt,
      maxQtyPerOrder: Number(req.body.maxQtyPerOrder),
      totalAvailable: Number(req.body.totalAvailable),
      totalUsed: Number(req.body.totalUsed ?? 0),
      isEnabled: req.body.isEnabled ?? true,
    });
    const full = await FlashOffer.findById(offer._id)
      .populate('productIds', 'name nameEn nameAr images price salePrice isActive')
      .lean();
    res.status(201).json(withComputedState(full));
  } catch (e) {
    next(e);
  }
});

router.patch('/:id', updateValidators, async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: errors.array()[0].msg });
    }
    const offer = await FlashOffer.findById(req.params.id);
    if (!offer) return res.status(404).json({ message: 'Not found' });

    const u = req.body;
    if (u.title != null) offer.title = u.title;
    if (u.imageUrl != null) offer.imageUrl = u.imageUrl;
    if (u.productIds != null) offer.productIds = u.productIds;
    if (u.originalPrice != null) offer.originalPrice = Number(u.originalPrice);
    if (u.discountedPrice != null) offer.discountedPrice = Number(u.discountedPrice);
    if (u.startsAt != null) {
      const parsed = parseDateOrNull(u.startsAt);
      if (parsed == null) return res.status(400).json({ message: 'Invalid startsAt' });
      offer.startsAt = parsed;
    }
    if (u.endsAt != null) {
      const parsed = parseDateOrNull(u.endsAt);
      if (parsed == null) return res.status(400).json({ message: 'Invalid endsAt' });
      offer.endsAt = parsed;
    }
    if (u.maxQtyPerOrder != null) offer.maxQtyPerOrder = Number(u.maxQtyPerOrder);
    if (u.totalAvailable != null) offer.totalAvailable = Number(u.totalAvailable);
    if (u.totalUsed != null) offer.totalUsed = Number(u.totalUsed);
    if (u.isEnabled != null) offer.isEnabled = Boolean(u.isEnabled);

    if (offer.startsAt >= offer.endsAt) {
      return res.status(400).json({ message: 'Invalid offer start/end time' });
    }
    if (offer.discountedPrice > offer.originalPrice) {
      return res.status(400).json({ message: 'Discounted price must be <= original price' });
    }
    await offer.save();
    const full = await FlashOffer.findById(offer._id)
      .populate('productIds', 'name nameEn nameAr images price salePrice isActive')
      .lean();
    res.json(withComputedState(full));
  } catch (e) {
    next(e);
  }
});

router.patch('/:id/toggle', async (req, res, next) => {
  try {
    const offer = await FlashOffer.findById(req.params.id);
    if (!offer) return res.status(404).json({ message: 'Not found' });
    offer.isEnabled = !offer.isEnabled;
    await offer.save();
    const full = await FlashOffer.findById(offer._id)
      .populate('productIds', 'name nameEn nameAr images price salePrice isActive')
      .lean();
    res.json(withComputedState(full));
  } catch (e) {
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await FlashOffer.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;

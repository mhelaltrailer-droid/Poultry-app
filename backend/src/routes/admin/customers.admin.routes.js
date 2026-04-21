import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import bcrypt from 'bcryptjs';
import { Order } from '../../models/Order.js';
import { User } from '../../models/User.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const customers = await User.find({ role: 'customer' })
      .select('phone name district addressDetail createdAt')
      .sort({ createdAt: -1 })
      .lean();
    res.json(customers);
  } catch (e) {
    next(e);
  }
});

router.post(
  '/',
  body('name').optional().isString().trim(),
  body('phone').trim().notEmpty().isLength({ min: 8, max: 20 }),
  body('password').notEmpty().isLength({ min: 4, max: 128 }),
  body('district').optional().isString().trim(),
  body('addressDetail').optional().isString().trim(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const phone = req.body.phone.replace(/\s/g, '');
      const exists = await User.findOne({ phone });
      if (exists) {
        return res.status(409).json({ message: 'Phone already registered' });
      }
      const passwordHash = await bcrypt.hash(req.body.password, 10);
      const user = await User.create({
        phone,
        passwordHash,
        name: req.body.name ?? '',
        role: 'customer',
        district: req.body.district ?? '',
        addressDetail: req.body.addressDetail ?? '',
      });
      res.status(201).json({
        _id: user._id,
        phone: user.phone,
        name: user.name,
        district: user.district,
        addressDetail: user.addressDetail,
      });
    } catch (e) {
      next(e);
    }
  }
);

router.patch(
  '/:id',
  body('name').optional().isString().trim(),
  body('phone').optional().trim().isLength({ min: 8, max: 20 }),
  body('password').optional().isLength({ min: 4, max: 128 }),
  body('district').optional().isString().trim(),
  body('addressDetail').optional().isString().trim(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const user = await User.findOne({
        _id: req.params.id,
        role: 'customer',
      }).select('+passwordHash');
      if (!user) return res.status(404).json({ message: 'Not found' });
      const u = req.body;
      if (u.phone != null) {
        const p = u.phone.replace(/\s/g, '');
        const clash = await User.findOne({ phone: p, _id: { $ne: user._id } });
        if (clash) return res.status(409).json({ message: 'Phone already in use' });
        user.phone = p;
      }
      if (u.name != null) user.name = u.name;
      if (u.district != null) user.district = u.district;
      if (u.addressDetail != null) user.addressDetail = u.addressDetail;
      if (u.password) user.passwordHash = await bcrypt.hash(u.password, 10);
      await user.save();
      res.json({
        _id: user._id,
        phone: user.phone,
        name: user.name,
        district: user.district,
        addressDetail: user.addressDetail,
      });
    } catch (e) {
      next(e);
    }
  }
);

router.delete('/:id', async (req, res, next) => {
  try {
    const user = await User.findOneAndDelete({
      _id: req.params.id,
      role: 'customer',
    });
    if (!user) return res.status(404).json({ message: 'Not found' });
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const customer = await User.findOne({
      _id: req.params.id,
      role: 'customer',
    })
      .select('phone name district addressDetail createdAt')
      .lean();
    if (!customer) return res.status(404).json({ message: 'Not found' });
    const orders = await Order.find({ customerId: customer._id })
      .sort({ createdAt: -1 })
      .select('orderNumber status total createdAt items')
      .lean();
    res.json({ ...customer, orders });
  } catch (e) {
    next(e);
  }
});

export default router;

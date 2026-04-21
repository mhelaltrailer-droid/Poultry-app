import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import bcrypt from 'bcryptjs';
import { User } from '../../models/User.js';

const router = Router();

const roleRule = body('role')
  .isIn(['customer', 'admin', 'app_admin', 'ops_admin'])
  .withMessage('Invalid role');

router.get('/', async (req, res, next) => {
  try {
    const users = await User.find()
      .select('phone name familyName role city district addressDetail deliveryNotes createdAt')
      .sort({ createdAt: -1 })
      .lean();
    res.json(users);
  } catch (e) {
    next(e);
  }
});

router.post(
  '/',
  body('name').optional().isString().trim(),
  body('familyName').optional().isString().trim(),
  body('phone').trim().notEmpty().isLength({ min: 8, max: 20 }),
  body('password').notEmpty().isLength({ min: 4, max: 128 }),
  roleRule,
  body('city').optional().isString().trim(),
  body('district').optional().isString().trim(),
  body('addressDetail').optional().isString().trim(),
  body('deliveryNotes').optional().isString().trim(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const { name = '', familyName = '', phone, password, role } = req.body;
      const exists = await User.findOne({ phone: phone.replace(/\s/g, '') });
      if (exists) {
        return res.status(409).json({ message: 'Phone already registered' });
      }
      const passwordHash = await bcrypt.hash(password, 10);
      const user = await User.create({
        phone: phone.replace(/\s/g, ''),
        passwordHash,
        name,
        familyName,
        role,
        city: req.body.city ?? '',
        district: req.body.district ?? '',
        addressDetail: req.body.addressDetail ?? '',
        deliveryNotes: req.body.deliveryNotes ?? '',
      });
      res.status(201).json({
        _id: user._id,
        phone: user.phone,
        name: user.name,
        familyName: user.familyName,
        role: user.role,
        city: user.city,
        district: user.district,
        addressDetail: user.addressDetail,
        deliveryNotes: user.deliveryNotes,
      });
    } catch (e) {
      next(e);
    }
  }
);

router.patch(
  '/:id',
  body('name').optional().isString().trim(),
  body('familyName').optional().isString().trim(),
  body('phone').optional().trim().isLength({ min: 8, max: 20 }),
  body('password').optional().isLength({ min: 4, max: 128 }),
  body('role').optional().isIn(['customer', 'admin', 'app_admin', 'ops_admin']),
  body('city').optional().isString().trim(),
  body('district').optional().isString().trim(),
  body('addressDetail').optional().isString().trim(),
  body('deliveryNotes').optional().isString().trim(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const user = await User.findById(req.params.id).select('+passwordHash');
      if (!user) return res.status(404).json({ message: 'Not found' });
      const u = req.body;
      if (u.phone != null) {
        const p = u.phone.replace(/\s/g, '');
        const clash = await User.findOne({ phone: p, _id: { $ne: user._id } });
        if (clash) return res.status(409).json({ message: 'Phone already in use' });
        user.phone = p;
      }
      if (u.name != null) user.name = u.name;
      if (u.familyName != null) user.familyName = u.familyName;
      if (u.role != null) user.role = u.role;
      if (u.city != null) user.city = u.city;
      if (u.district != null) user.district = u.district;
      if (u.addressDetail != null) user.addressDetail = u.addressDetail;
      if (u.deliveryNotes != null) user.deliveryNotes = u.deliveryNotes;
      if (u.password) user.passwordHash = await bcrypt.hash(u.password, 10);
      await user.save();
      res.json({
        _id: user._id,
        phone: user.phone,
        name: user.name,
        familyName: user.familyName,
        role: user.role,
        city: user.city,
        district: user.district,
        addressDetail: user.addressDetail,
        deliveryNotes: user.deliveryNotes,
      });
    } catch (e) {
      next(e);
    }
  }
);

router.delete('/:id', async (req, res, next) => {
  try {
    if (req.params.id === req.user.id) {
      return res.status(400).json({ message: 'Cannot delete your own account' });
    }
    await User.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;

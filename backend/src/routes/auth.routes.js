import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import bcrypt from 'bcryptjs';
import { User } from '../models/User.js';
import { signCustomerToken, signStaffToken } from '../utils/jwt.js';
import { normalizePhone } from '../utils/phone.js';

const staffRoles = new Set(['admin', 'app_admin', 'ops_admin']);

const router = Router();

const phoneRule = body('phone')
  .trim()
  .notEmpty()
  .isLength({ min: 8, max: 20 })
  .withMessage('Valid phone required');

router.post(
  '/register',
  body('name').trim().notEmpty().withMessage('Name required'),
  body('familyName').optional().isString().trim(),
  phoneRule,
  body('password').isLength({ min: 6, max: 128 }).withMessage('Password too short'),
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
      const phone = normalizePhone(req.body.phone);
      const exists = await User.findOne({ phone });
      if (exists) {
        return res.status(409).json({ message: 'Phone already registered' });
      }
      const passwordHash = await bcrypt.hash(req.body.password, 10);
      const user = await User.create({
        phone,
        passwordHash,
        name: String(req.body.name ?? '').trim(),
        familyName: String(req.body.familyName ?? '').trim(),
        role: 'customer',
        city: String(req.body.city ?? '').trim(),
        district: String(req.body.district ?? '').trim(),
        addressDetail: String(req.body.addressDetail ?? '').trim(),
        deliveryNotes: String(req.body.deliveryNotes ?? '').trim(),
      });
      const token = signCustomerToken({
        userId: user._id.toString(),
        phone: user.phone,
      });
      res.status(201).json({
        token,
        user: {
          id: user._id,
          phone: user.phone,
          name: user.name,
          role: user.role,
          familyName: user.familyName,
          city: user.city,
          district: user.district,
          addressDetail: user.addressDetail,
          deliveryNotes: user.deliveryNotes,
        },
      });
    } catch (e) {
      next(e);
    }
  }
);

router.post(
  '/login',
  phoneRule,
  body('password').notEmpty().withMessage('Password required'),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const phone = normalizePhone(req.body.phone);
      const user = await User.findOne({ phone }).select('+passwordHash');
      if (!user?.passwordHash) {
        return res.status(401).json({ message: 'Invalid phone or password' });
      }
      const ok = await bcrypt.compare(req.body.password, user.passwordHash);
      if (!ok) {
        return res.status(401).json({ message: 'Invalid phone or password' });
      }

      const baseUser = {
        id: user._id,
        phone: user.phone,
        name: user.name,
        role: user.role,
        district: user.district ?? '',
        addressDetail: user.addressDetail ?? '',
      };

      if (user.role === 'customer') {
        const token = signCustomerToken({
          userId: user._id.toString(),
          phone: user.phone,
        });
        return res.json({ token, user: baseUser });
      }

      if (staffRoles.has(user.role)) {
        const token = signStaffToken({
          userId: user._id.toString(),
          role: user.role,
        });
        return res.json({ token, user: baseUser });
      }

      return res.status(403).json({ message: 'Account role not supported' });
    } catch (e) {
      next(e);
    }
  }
);

export default router;

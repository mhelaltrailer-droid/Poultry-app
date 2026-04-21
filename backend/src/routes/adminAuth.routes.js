import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import bcrypt from 'bcryptjs';
import { User } from '../models/User.js';
import { signStaffToken } from '../utils/jwt.js';
import { normalizePhone } from '../utils/phone.js';

const router = Router();

router.post(
  '/login',
  body('phone')
    .trim()
    .notEmpty()
    .isLength({ min: 8, max: 20 })
    .withMessage('Valid phone required'),
  body('password').notEmpty(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const phone = normalizePhone(req.body.phone);
      const user = await User.findOne({
        phone,
        role: { $in: ['admin', 'app_admin', 'ops_admin'] },
      }).select('+passwordHash');
      if (!user?.passwordHash) {
        return res.status(401).json({ message: 'Invalid phone or password' });
      }
      const ok = await bcrypt.compare(req.body.password, user.passwordHash);
      if (!ok) return res.status(401).json({ message: 'Invalid phone or password' });

      const token = signStaffToken({
        userId: user._id.toString(),
        role: user.role,
      });
      res.json({
        token,
        user: {
          id: user._id,
          phone: user.phone,
          name: user.name,
          role: user.role,
        },
      });
    } catch (e) {
      next(e);
    }
  }
);

export default router;

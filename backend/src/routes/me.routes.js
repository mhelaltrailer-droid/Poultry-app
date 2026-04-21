import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { authenticate, requireCustomer } from '../middleware/auth.js';
import { User } from '../models/User.js';

const router = Router();
router.use(authenticate, requireCustomer);

router.get('/', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).lean();
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({
      id: user._id,
      phone: user.phone,
      name: user.name,
      addresses: user.addresses || [],
    });
  } catch (e) {
    next(e);
  }
});

router.patch(
  '/',
  body('name').optional().isString().trim(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const updates = {};
      if (req.body.name != null) updates.name = req.body.name;
      const user = await User.findByIdAndUpdate(req.user.id, updates, {
        new: true,
      }).lean();
      res.json({
        id: user._id,
        phone: user.phone,
        name: user.name,
      });
    } catch (e) {
      next(e);
    }
  }
);

router.post(
  '/fcm-token',
  body('token').notEmpty().isString(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const token = req.body.token.trim();
      await User.findByIdAndUpdate(req.user.id, {
        $addToSet: { fcmTokens: token },
      });
      res.json({ ok: true });
    } catch (e) {
      next(e);
    }
  }
);

router.delete('/fcm-token', body('token').notEmpty(), async (req, res, next) => {
  try {
    const token = req.body.token?.trim();
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { fcmTokens: token },
    });
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;

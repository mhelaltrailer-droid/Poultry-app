import { Router } from 'express';
import { District } from '../models/District.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const list = await District.find({ isActive: true })
      .sort({ sortOrder: 1, name: 1 })
      .lean();
    res.json(list);
  } catch (e) {
    next(e);
  }
});

export default router;

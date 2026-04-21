import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { District } from '../../models/District.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const list = await District.find().sort({ sortOrder: 1, name: 1 }).lean();
    res.json(list);
  } catch (e) {
    next(e);
  }
});

router.post(
  '/',
  body('name').trim().notEmpty(),
  body('isActive').optional().isBoolean(),
  body('sortOrder').optional().isInt({ min: 0 }),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const created = await District.create({
        name: req.body.name.trim(),
        isActive: req.body.isActive ?? true,
        sortOrder: req.body.sortOrder ?? 0,
      });
      res.status(201).json(created);
    } catch (e) {
      if (e.code === 11000) {
        return res.status(400).json({ message: 'District already exists' });
      }
      next(e);
    }
  }
);

router.patch(
  '/:id',
  body('name').optional().trim().notEmpty(),
  body('isActive').optional().isBoolean(),
  body('sortOrder').optional().isInt({ min: 0 }),
  async (req, res, next) => {
    try {
      const d = await District.findById(req.params.id);
      if (!d) return res.status(404).json({ message: 'Not found' });
      if (req.body.name != null) d.name = req.body.name.trim();
      if (req.body.isActive != null) d.isActive = req.body.isActive;
      if (req.body.sortOrder != null) d.sortOrder = req.body.sortOrder;
      await d.save();
      res.json(d);
    } catch (e) {
      if (e.code === 11000) {
        return res.status(400).json({ message: 'District already exists' });
      }
      next(e);
    }
  }
);

router.delete('/:id', async (req, res, next) => {
  try {
    await District.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;

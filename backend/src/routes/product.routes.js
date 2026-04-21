import { Router } from 'express';
import { Product } from '../models/Product.js';
import { rankProductsByQuery } from '../utils/fuzzyProductSearch.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const { category, q } = req.query;
    const filter = { isActive: true };
    if (category) filter.category = category;

    const qStr = typeof q === 'string' ? q.trim() : '';

    if (qStr.length > 0) {
      const base = await Product.find(filter).sort({ createdAt: -1 }).lean();
      const ranked = rankProductsByQuery(base, qStr);
      res.json(ranked.map((x) => x.product));
      return;
    }

    const products = await Product.find(filter).sort({ createdAt: -1 }).lean();
    res.json(products);
  } catch (e) {
    next(e);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const p = await Product.findOne({
      _id: req.params.id,
      isActive: true,
    }).lean();
    if (!p) return res.status(404).json({ message: 'Product not found' });
    res.json(p);
  } catch (e) {
    next(e);
  }
});

export default router;

import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { Product } from '../../models/Product.js';
import { slugify } from '../../utils/slug.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const products = await Product.find().sort({ createdAt: -1 }).lean();
    res.json(products);
  } catch (e) {
    next(e);
  }
});

router.post(
  '/',
  body('name').notEmpty().trim(),
  body('description').optional().isString(),
  body('nameEn').optional().isString(),
  body('nameAr').optional().isString(),
  body('descriptionEn').optional().isString(),
  body('descriptionAr').optional().isString(),
  body('images').optional().isArray(),
  body('price').isFloat({ min: 0 }),
  body('weightValue').isFloat({ min: 0 }),
  body('weightUnit').optional().isIn(['g', 'kg', 'lb', 'piece']),
  body('stock').optional().isInt({ min: 0 }),
  body('maxOrderQty').optional().isInt({ min: 1 }),
  body('category').optional().isString(),
  body('isActive').optional().isBoolean(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      let base = slugify(req.body.name);
      let slug = base;
      let n = 0;
      while (await Product.exists({ slug })) {
        n += 1;
        slug = `${base}-${n}`;
      }
      const product = await Product.create({
        name: req.body.name,
        nameEn: req.body.nameEn ?? '',
        nameAr: req.body.nameAr ?? '',
        slug,
        description: req.body.description ?? '',
        descriptionEn: req.body.descriptionEn ?? '',
        descriptionAr: req.body.descriptionAr ?? '',
        images: req.body.images ?? [],
        price: req.body.price,
        salePrice:
          req.body.salePrice === undefined || req.body.salePrice === ''
            ? null
            : Number(req.body.salePrice),
        weightValue: req.body.weightValue,
        weightUnit: req.body.weightUnit ?? 'kg',
        stock: req.body.stock ?? 0,
        maxOrderQty: req.body.maxOrderQty ?? 50,
        category: req.body.category ?? 'poultry',
        isActive: req.body.isActive ?? true,
      });
      res.status(201).json(product);
    } catch (e) {
      next(e);
    }
  }
);

router.patch(
  '/:id',
  body('name').optional().trim().notEmpty(),
  body('description').optional().isString(),
  body('nameEn').optional().isString(),
  body('nameAr').optional().isString(),
  body('descriptionEn').optional().isString(),
  body('descriptionAr').optional().isString(),
  body('images').optional().isArray(),
  body('price').optional().isFloat({ min: 0 }),
  body('weightValue').optional().isFloat({ min: 0 }),
  body('weightUnit').optional().isIn(['g', 'kg', 'lb', 'piece']),
  body('stock').optional().isInt({ min: 0 }),
  body('maxOrderQty').optional().isInt({ min: 1 }),
  body('category').optional().isString(),
  body('isActive').optional().isBoolean(),
  async (req, res, next) => {
    try {
      const product = await Product.findById(req.params.id);
      if (!product) return res.status(404).json({ message: 'Not found' });
      const u = req.body;
      if (u.name != null) {
        product.name = u.name;
        let base = slugify(u.name);
        let slug = base;
        let n = 0;
        while (await Product.exists({ slug, _id: { $ne: product._id } })) {
          n += 1;
          slug = `${base}-${n}`;
        }
        product.slug = slug;
      }
      if (u.description != null) product.description = u.description;
      if (u.nameEn != null) product.nameEn = u.nameEn;
      if (u.nameAr != null) product.nameAr = u.nameAr;
      if (u.descriptionEn != null) product.descriptionEn = u.descriptionEn;
      if (u.descriptionAr != null) product.descriptionAr = u.descriptionAr;
      if (u.images != null) product.images = u.images;
      if (u.price != null) product.price = u.price;
      if (u.salePrice !== undefined) {
        product.salePrice =
          u.salePrice === null || u.salePrice === '' ? null : Number(u.salePrice);
      }
      if (u.weightValue != null) product.weightValue = u.weightValue;
      if (u.weightUnit != null) product.weightUnit = u.weightUnit;
      if (u.stock != null) product.stock = u.stock;
      if (u.maxOrderQty != null) product.maxOrderQty = u.maxOrderQty;
      if (u.category != null) product.category = u.category;
      if (u.isActive != null) product.isActive = u.isActive;
      await product.save();
      res.json(product);
    } catch (e) {
      next(e);
    }
  }
);

router.delete('/:id', async (req, res, next) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;

import 'dotenv/config';
import mongoose from 'mongoose';
import { Product } from '../models/Product.js';
import { slugify } from '../utils/slug.js';

const demoProducts = [
  {
    name: 'دجاجة كاملة طازجة',
    nameEn: 'Fresh Whole Chicken',
    nameAr: 'دجاجة كاملة طازجة',
    description: 'Cleaned fresh whole chicken, ideal for roasting and family meals.',
    descriptionEn: 'Cleaned fresh whole chicken, ideal for roasting and family meals.',
    descriptionAr: 'دجاجة كاملة طازجة منظفة، مناسبة للشوي ووجبات العائلة.',
    images: ['asset:demo_products/fresh_whole_chicken.webp'],
    price: 210,
    salePrice: 189,
    weightValue: 1.2,
    weightUnit: 'kg',
    stock: 85,
    maxOrderQty: 6,
    category: 'whole-chicken',
    isActive: true,
  },
  {
    name: 'صدور دجاج فيليه',
    nameEn: 'Chicken Breast Fillet',
    nameAr: 'صدور دجاج فيليه',
    description: 'Premium skinless breast fillet, perfect for grilling and healthy meals.',
    descriptionEn: 'Premium skinless breast fillet, perfect for grilling and healthy meals.',
    descriptionAr: 'صدور دجاج فيليه ممتازة بدون جلد، مناسبة للشوي والوجبات الصحية.',
    images: ['asset:demo_products/chicken_breast_fillet.webp'],
    price: 255,
    salePrice: 229,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 70,
    maxOrderQty: 5,
    category: 'fillet',
    isActive: true,
  },
  {
    name: 'أوراك دجاج',
    nameEn: 'Chicken Thighs',
    nameAr: 'أوراك دجاج',
    description: 'Juicy chicken thighs with balanced fat for rich flavor.',
    descriptionEn: 'Juicy chicken thighs with balanced fat for rich flavor.',
    descriptionAr: 'أوراك دجاج طرية بطعم غني ومناسبة للطبخ اليومي.',
    images: ['asset:demo_products/chicken_thighs.webp'],
    price: 185,
    salePrice: 169,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 95,
    maxOrderQty: 8,
    category: 'cuts',
    isActive: true,
  },
  {
    name: 'أجنحة دجاج',
    nameEn: 'Chicken Wings',
    nameAr: 'أجنحة دجاج',
    description: 'Tender wings for crispy fried or spicy oven recipes.',
    descriptionEn: 'Tender wings for crispy fried or spicy oven recipes.',
    descriptionAr: 'أجنحة دجاج طرية للقلي المقرمش أو الوصفات الحارة.',
    images: ['asset:demo_products/chicken_wings.webp'],
    price: 165,
    salePrice: 149,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 92,
    maxOrderQty: 10,
    category: 'cuts',
    isActive: true,
  },
  {
    name: 'دبابيس دجاج',
    nameEn: 'Chicken Drumsticks',
    nameAr: 'دبابيس دجاج',
    description: 'Fresh drumsticks, great for oven and air fryer recipes.',
    descriptionEn: 'Fresh drumsticks, great for oven and air fryer recipes.',
    descriptionAr: 'دبابيس دجاج طازجة، مناسبة للفرن والقلاية الهوائية.',
    images: ['asset:demo_products/chicken_drumsticks.webp'],
    price: 175,
    salePrice: 159,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 88,
    maxOrderQty: 8,
    category: 'cuts',
    isActive: true,
  },
  {
    name: 'كبد وقوانص',
    nameEn: 'Chicken Liver and Gizzards',
    nameAr: 'كبد وقوانص',
    description: 'Fresh liver and gizzards cleaned and ready to cook.',
    descriptionEn: 'Fresh liver and gizzards cleaned and ready to cook.',
    descriptionAr: 'كبد وقوانص دجاج طازجة ومنظفة وجاهزة للطهي.',
    images: ['asset:demo_products/chicken_liver_gizzards.webp'],
    price: 145,
    salePrice: 129,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 60,
    maxOrderQty: 6,
    category: 'offal',
    isActive: true,
  },
  {
    name: 'صدور دجاج فيليه شرائح',
    nameEn: 'Sliced Chicken Breast Fillet',
    nameAr: 'صدور دجاج فيليه شرائح',
    description: 'Thin sliced breast fillet for quick cooking and sandwiches.',
    descriptionEn: 'Thin sliced breast fillet for quick cooking and sandwiches.',
    descriptionAr: 'شرائح صدور دجاج فيليه رفيعة للطبخ السريع والسندوتشات.',
    images: ['asset:demo_products/sliced_chicken_breast_fillet.webp'],
    price: 245,
    salePrice: 219,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 62,
    maxOrderQty: 5,
    category: 'fillet',
    isActive: true,
  },
  {
    name: 'شيش طاووق',
    nameEn: 'Chicken Shish Tawook',
    nameAr: 'شيش طاووق',
    description: 'Chicken cubes prepared for grilling and quick family meals.',
    descriptionEn: 'Chicken cubes prepared for grilling and quick family meals.',
    descriptionAr: 'مكعبات دجاج مجهزة للشوي والوجبات السريعة.',
    images: ['asset:demo_products/chicken_shish_tawook.webp'],
    price: 265,
    salePrice: 239,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 48,
    maxOrderQty: 4,
    category: 'marinated',
    isActive: true,
  },
  {
    name: 'كبد دجاج',
    nameEn: 'Chicken Liver',
    nameAr: 'كبد دجاج',
    description: 'Fresh chicken liver cleaned and ready for cooking.',
    descriptionEn: 'Fresh chicken liver cleaned and ready for cooking.',
    descriptionAr: 'كبد دجاج طازج ومنظف وجاهز للطهي.',
    images: ['asset:demo_products/chicken_liver.webp'],
    price: 135,
    salePrice: 119,
    weightValue: 1,
    weightUnit: 'kg',
    stock: 64,
    maxOrderQty: 6,
    category: 'offal',
    isActive: true,
  },
];

async function upsertProduct(raw) {
  const baseSlug = slugify(raw.nameEn || raw.name || '');
  if (!baseSlug) return;
  const existing = await Product.findOne({ slug: baseSlug });
  if (existing) {
    Object.assign(existing, raw);
    await existing.save();
    console.log('Updated product:', existing.nameEn || existing.name);
    return;
  }
  await Product.create({
    ...raw,
    slug: baseSlug,
  });
  console.log('Created product:', raw.nameEn || raw.name);
}

async function run() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('MONGODB_URI required');
    process.exit(1);
  }
  await mongoose.connect(uri);
  const allowedSlugs = demoProducts
    .map((p) => slugify(p.nameEn || p.name || ''))
    .filter(Boolean);
  await Product.deleteMany({ slug: { $nin: allowedSlugs } });
  for (const p of demoProducts) {
    await upsertProduct(p);
  }
  console.log(`Catalog seed completed: ${demoProducts.length} items`);
  await mongoose.disconnect();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

import mongoose from 'mongoose';

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    nameEn: { type: String, default: '', trim: true },
    nameAr: { type: String, default: '', trim: true },
    slug: { type: String, required: true, unique: true, lowercase: true },
    description: { type: String, default: '' },
    descriptionEn: { type: String, default: '' },
    descriptionAr: { type: String, default: '' },
    images: [{ type: String }],
    price: { type: Number, required: true, min: 0 },
    salePrice: { type: Number, min: 0, default: null },
    weightValue: { type: Number, required: true, min: 0 },
    weightUnit: { type: String, enum: ['g', 'kg', 'lb', 'piece'], default: 'kg' },
    stock: { type: Number, default: 0, min: 0 },
    maxOrderQty: { type: Number, default: 50, min: 1 },
    category: { type: String, default: 'poultry', trim: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

productSchema.index({ isActive: 1, category: 1 });

export const Product = mongoose.model('Product', productSchema);

import mongoose from 'mongoose';

const promotionSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, unique: true, uppercase: true, trim: true },
    discountType: { type: String, enum: ['percent', 'fixed'], required: true },
    discountValue: { type: Number, required: true, min: 0 },
    minOrderAmount: { type: Number, default: 0 },
    maxDiscount: { type: Number, default: null },
    expiresAt: { type: Date, default: null },
    isActive: { type: Boolean, default: true },
    usageLimit: { type: Number, default: null },
    usageCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const Promotion = mongoose.model('Promotion', promotionSchema);

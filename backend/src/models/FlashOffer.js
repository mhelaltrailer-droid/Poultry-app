import mongoose from 'mongoose';

const flashOfferSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    imageUrl: { type: String, default: '', trim: true },
    productIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true }],
    originalPrice: { type: Number, required: true, min: 0 },
    discountedPrice: { type: Number, required: true, min: 0 },
    startsAt: { type: Date, required: true },
    endsAt: { type: Date, required: true },
    maxQtyPerOrder: { type: Number, required: true, min: 1, default: 1 },
    totalAvailable: { type: Number, required: true, min: 1, default: 1 },
    totalUsed: { type: Number, required: true, min: 0, default: 0 },
    isEnabled: { type: Boolean, default: true },
  },
  { timestamps: true }
);

flashOfferSchema.index({ isEnabled: 1, startsAt: 1, endsAt: 1 });

export const FlashOffer = mongoose.model('FlashOffer', flashOfferSchema);

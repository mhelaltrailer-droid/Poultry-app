import { Promotion } from '../models/Promotion.js';

export async function validateAndComputeDiscount(code, subtotal) {
  if (!code?.trim()) return { discount: 0, promotion: null };
  const promo = await Promotion.findOne({
    code: code.trim().toUpperCase(),
    isActive: true,
  });
  if (!promo) throw Object.assign(new Error('Invalid promo code'), { status: 400 });
  if (promo.expiresAt && promo.expiresAt < new Date()) {
    throw Object.assign(new Error('Promo code expired'), { status: 400 });
  }
  if (promo.usageLimit != null && promo.usageCount >= promo.usageLimit) {
    throw Object.assign(new Error('Promo code usage limit reached'), { status: 400 });
  }
  if (subtotal < promo.minOrderAmount) {
    throw Object.assign(
      new Error(`Minimum order amount is ${promo.minOrderAmount}`),
      { status: 400 }
    );
  }
  let discount =
    promo.discountType === 'percent'
      ? (subtotal * promo.discountValue) / 100
      : promo.discountValue;
  if (promo.maxDiscount != null && discount > promo.maxDiscount) {
    discount = promo.maxDiscount;
  }
  discount = Math.min(discount, subtotal);
  return { discount: Math.round(discount * 100) / 100, promotion: promo };
}

export async function incrementPromoUsage(promotionId, session = null) {
  if (!promotionId) return;
  await Promotion.updateOne(
    { _id: promotionId },
    { $inc: { usageCount: 1 } },
    session ? { session } : {}
  );
}

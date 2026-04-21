import { Router } from 'express';
import { FlashOffer } from '../models/FlashOffer.js';

const router = Router();

function withComputedState(offer) {
  const now = new Date();
  const remaining = Math.max(0, (offer.totalAvailable ?? 0) - (offer.totalUsed ?? 0));
  const isWithinTime =
    offer.startsAt != null &&
    offer.endsAt != null &&
    new Date(offer.startsAt) <= now &&
    new Date(offer.endsAt) >= now;
  const isLive = Boolean(offer.isEnabled) && isWithinTime && remaining > 0;
  return { ...offer, remainingCount: remaining, isLive };
}

router.get('/', async (req, res, next) => {
  try {
    const list = await FlashOffer.find()
      .sort({ startsAt: 1, createdAt: -1 })
      .populate('productIds', 'name nameEn nameAr images price salePrice isActive')
      .lean();
    const liveOnly = String(req.query.live ?? 'true') !== 'false';
    const mapped = list.map(withComputedState);
    res.json(liveOnly ? mapped.filter((x) => x.isLive) : mapped);
  } catch (e) {
    next(e);
  }
});

export default router;

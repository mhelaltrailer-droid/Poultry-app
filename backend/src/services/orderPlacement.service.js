import mongoose from 'mongoose';
import { Product } from '../models/Product.js';
import { Order } from '../models/Order.js';
import { OrderSequence } from '../models/OrderSequence.js';
import { User } from '../models/User.js';
import { resolveProductName } from '../utils/productLocale.js';
import {
  validateAndComputeDiscount,
  incrementPromoUsage,
} from './promotion.service.js';
import { sendPushToUser } from './notification.service.js';

/**
 * Creates an order (customer or guest). Caller runs inside transaction/session.
 * @param {object} opts
 * @param {mongoose.ClientSession} opts.session
 * @param {string|null} opts.customerId - Mongo id string when logged-in customer
 * @param {string} [opts.guestName]
 * @param {string} [opts.guestPhone]
 * @param {Array} opts.items - [{ productId, quantity }]
 * @param {object} opts.deliveryAddress
 * @param {number} opts.deliveryFee
 * @param {string} [opts.promoCode]
 * @param {string} [opts.notes]
 * @param {string} [opts.locale] — 'en' | 'ar' for item name snapshot
 */
function _formatOrderNumber(dayKey, seq) {
  return `${dayKey}${String(seq)}`;
}

function _toDayKey(date) {
  const yy = String(date.getFullYear()).slice(-2);
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${yy}${mm}${dd}`;
}

async function _nextOrderNumber(session) {
  const dayKey = _toDayKey(new Date());
  const options = { new: true, upsert: true };
  if (session) options.session = session;
  const seqDoc = await OrderSequence.findOneAndUpdate(
    { dayKey },
    { $inc: { seq: 1 }, $setOnInsert: { dayKey } },
    options
  );
  return _formatOrderNumber(dayKey, seqDoc.seq);
}

export async function placeOrder({
  session,
  customerId,
  guestName = '',
  guestPhone = '',
  items,
  deliveryAddress,
  deliveryFee = 0,
  promoCode,
  notes = '',
  locale = 'en',
}) {
  const lineItems = [];
  let subtotal = 0;

  for (const line of items) {
    const productQuery = Product.findById(line.productId);
    if (session) productQuery.session(session);
    const product = await productQuery;
    if (!product || !product.isActive) {
      const e = new Error('Invalid product in cart');
      e.status = 400;
      throw e;
    }
    const displayName = resolveProductName(product, locale);
    if (product.stock < line.quantity) {
      const e = new Error(`Insufficient stock for ${displayName}`);
      e.status = 400;
      throw e;
    }
    const maxPer = product.maxOrderQty ?? 50;
    if (line.quantity > maxPer) {
      const e = new Error(`Max ${maxPer} per order for ${displayName}`);
      e.status = 400;
      throw e;
    }
    const unit =
      product.salePrice != null && !Number.isNaN(product.salePrice)
        ? product.salePrice
        : product.price;
    const lineTotal = unit * line.quantity;
    subtotal += lineTotal;
    lineItems.push({
      productId: product._id,
      name: displayName,
      price: unit,
      quantity: line.quantity,
      weightSnapshot: `${product.weightValue}${product.weightUnit}`,
      image: product.images?.[0] || '',
    });
  }

  let discountAmount = 0;
  let promotionRef = null;
  if (promoCode) {
    const { discount, promotion } = await validateAndComputeDiscount(
      promoCode,
      subtotal
    );
    discountAmount = discount;
    promotionRef = promotion;
  }

  const total = Math.max(0, subtotal - discountAmount + Number(deliveryFee));

  for (let i = 0; i < items.length; i++) {
    await Product.updateOne(
      { _id: items[i].productId },
      { $inc: { stock: -items[i].quantity } },
      session ? { session } : {}
    );
  }

  const orderPayload = {
    customerId: customerId || null,
    guestName: customerId ? '' : String(guestName || '').trim(),
    guestPhone: customerId ? '' : String(guestPhone || '').trim(),
    items: lineItems,
    deliveryAddress,
    subtotal,
    deliveryFee: Number(deliveryFee),
    discountAmount,
    total,
    promoCode: promoCode?.trim().toUpperCase() || '',
    notes: notes || '',
    status: 'pending',
    orderNumber: await _nextOrderNumber(session),
  };

  const [order] = session
    ? await Order.create([orderPayload], { session })
    : await Order.create([orderPayload]);

  if (promotionRef) {
    await incrementPromoUsage(promotionRef._id, session);
  }

  if (customerId) {
    const user = await User.findById(customerId);
    await sendPushToUser(
      user?.fcmTokens || [],
      'Order placed',
      `Your order ${order.orderNumber} is pending confirmation.`,
      { orderId: order._id.toString(), type: 'order_placed' }
    );
  }

  return order;
}

export async function placeOrderInTransaction(opts) {
  return placeOrder(opts);
}

import { randomBytes } from 'crypto';
import mongoose from 'mongoose';

const orderItemSchema = new mongoose.Schema(
  {
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    name: String,
    price: Number,
    quantity: { type: Number, min: 1 },
    weightSnapshot: String,
    image: String,
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    orderNumber: { type: String, unique: true },
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    guestName: { type: String, default: '' },
    guestPhone: { type: String, default: '' },
    items: [orderItemSchema],
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'preparing', 'on_the_way', 'delivered', 'cancelled'],
      default: 'pending',
    },
    deliveryAddress: {
      label: String,
      line1: String,
      line2: String,
      city: String,
      region: String,
      postalCode: String,
      phone: String,
    },
    assignedDelivery: { type: String, default: '' },
    promoCode: { type: String, default: '' },
    discountAmount: { type: Number, default: 0 },
    subtotal: { type: Number, required: true },
    deliveryFee: { type: Number, default: 0 },
    total: { type: Number, required: true },
    notes: { type: String, default: '' },
    cancellationReason: { type: String, default: '' },
  },
  { timestamps: true }
);

orderSchema.index({ customerId: 1, createdAt: -1 });
orderSchema.index({ status: 1, createdAt: -1 });

orderSchema.pre('save', function (next) {
  if (!this.orderNumber) {
    const suffix = randomBytes(3).toString('hex').toUpperCase();
    this.orderNumber = `DTD-${Date.now()}-${suffix}`;
  }
  next();
});

export const Order = mongoose.model('Order', orderSchema);

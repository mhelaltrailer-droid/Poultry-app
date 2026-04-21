import mongoose from 'mongoose';

const orderSequenceSchema = new mongoose.Schema(
  {
    dayKey: { type: String, required: true, unique: true },
    seq: { type: Number, default: 99 },
  },
  { timestamps: true }
);

export const OrderSequence = mongoose.model('OrderSequence', orderSequenceSchema);

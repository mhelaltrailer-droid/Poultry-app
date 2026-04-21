import mongoose from 'mongoose';

const addressSchema = new mongoose.Schema(
  {
    label: String,
    line1: { type: String, required: true },
    line2: String,
    city: { type: String, required: true },
    region: String,
    postalCode: String,
    phone: String,
  },
  { _id: true }
);

const userSchema = new mongoose.Schema(
  {
    phone: { type: String, sparse: true, unique: true, trim: true },
    email: { type: String, sparse: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, select: false },
    name: { type: String, trim: true, default: '' },
    familyName: { type: String, trim: true, default: '' },
    role: {
      type: String,
      enum: ['customer', 'admin', 'app_admin', 'ops_admin'],
      default: 'customer',
    },
    city: { type: String, trim: true, default: '' },
    district: { type: String, trim: true, default: '' },
    addressDetail: { type: String, trim: true, default: '' },
    deliveryNotes: { type: String, trim: true, default: '' },
    fcmTokens: [{ type: String }],
    addresses: [addressSchema],
  },
  { timestamps: true }
);

// phone/email: unique:true already creates indexes — avoid duplicate schema.index()

export const User = mongoose.model('User', userSchema);

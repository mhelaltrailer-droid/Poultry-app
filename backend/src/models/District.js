import mongoose from 'mongoose';

const districtSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, unique: true },
    isActive: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
  },
  { timestamps: true }
);

districtSchema.index({ isActive: 1, sortOrder: 1, name: 1 });

export const District = mongoose.model('District', districtSchema);

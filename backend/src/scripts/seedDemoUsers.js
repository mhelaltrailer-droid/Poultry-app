import 'dotenv/config';
import bcrypt from 'bcryptjs';
import mongoose from 'mongoose';
import { User } from '../models/User.js';

/**
 * Demo accounts (Egypt-style numbers, no country code required):
 * - App admin (لوحة التحكم): 01111989094 / 123456
 * - Customer: 01157563840 / 123456 — test purchases
 * - Legacy admin: 01550490790 / 0000 — dashboard (web)
 */
async function upsertPasswordUser({ phone, password, role, name }) {
  const passwordHash = await bcrypt.hash(password, 10);
  const existing = await User.findOne({ phone });
  if (existing) {
    existing.passwordHash = passwordHash;
    existing.name = name;
    existing.role = role;
    await existing.save();
    console.log('Updated:', phone, role);
    return;
  }
  await User.create({ phone, passwordHash, role, name });
  console.log('Created:', phone, role);
}

async function run() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('MONGODB_URI required');
    process.exit(1);
  }
  await mongoose.connect(uri);

  await upsertPasswordUser({
    phone: '01111989094',
    password: '123456',
    role: 'app_admin',
    name: 'مسؤول التطبيق',
  });

  await upsertPasswordUser({
    phone: '01157563840',
    password: '123456',
    role: 'customer',
    name: 'عميل تجريبي',
  });

  await upsertPasswordUser({
    phone: '01550490790',
    password: '0000',
    role: 'admin',
    name: 'مسؤول (قديم)',
  });

  console.log('Demo users ready.');
  await mongoose.disconnect();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

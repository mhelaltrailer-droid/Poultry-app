import 'dotenv/config';
import mongoose from 'mongoose';
import { District } from '../models/District.js';

const names = [
  'Nasr City',
  'Heliopolis',
  'Maadi',
  'Dokki',
  'Mohandessin',
  'Zamalek',
  '6th October',
  'Sheikh Zayed',
  'Haram',
  'Shoubra',
];

async function run() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('MONGODB_URI required');
    process.exit(1);
  }
  await mongoose.connect(uri);
  for (let i = 0; i < names.length; i += 1) {
    const name = names[i];
    const existing = await District.findOne({ name });
    if (existing) {
      existing.isActive = true;
      existing.sortOrder = i;
      await existing.save();
      console.log('Updated district:', name);
    } else {
      await District.create({ name, isActive: true, sortOrder: i });
      console.log('Created district:', name);
    }
  }
  await mongoose.disconnect();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

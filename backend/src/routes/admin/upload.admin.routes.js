import { Router } from 'express';
import multer from 'multer';
import streamifier from 'streamifier';
import { cloudinary, isCloudinaryReady } from '../../config/cloudinary.js';

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
});

router.post('/', upload.single('file'), async (req, res, next) => {
  try {
    if (!isCloudinaryReady()) {
      return res.status(503).json({
        message: 'Image upload unavailable: configure Cloudinary in .env',
      });
    }
    if (!req.file?.buffer) {
      return res.status(400).json({ message: 'file required (field: file)' });
    }
    const folder = process.env.CLOUDINARY_FOLDER || 'daytoday/products';
    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder, resource_type: 'image' },
        (err, r) => (err ? reject(err) : resolve(r))
      );
      streamifier.createReadStream(req.file.buffer).pipe(stream);
    });
    res.json({ url: result.secure_url, publicId: result.public_id });
  } catch (e) {
    if (e?.http_code) {
      return res.status(502).json({ message: 'Upload failed', detail: e.message });
    }
    next(e);
  }
});

export default router;

import 'dotenv/config';
import app from './app.js';
import { connectDatabase } from './config/database.js';
import { configureCloudinary } from './config/cloudinary.js';
import { initFirebaseAdmin } from './config/firebase.js';

const port = Number(process.env.PORT) || 4000;

async function main() {
  await connectDatabase();
  if (configureCloudinary()) {
    console.log('Cloudinary configured');
  } else {
    console.warn('Cloudinary not configured — image upload disabled');
  }
  await initFirebaseAdmin();

  const server = app.listen(port, '0.0.0.0', () => {
    console.log(`DAY TO DAY API listening on http://127.0.0.1:${port} (and LAN)`);
  });
  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(
        `Port ${port} is already in use. Stop the other process or set PORT in .env.\n` +
          `Windows: netstat -ano | findstr :${port}  then  taskkill /PID <pid> /F`
      );
    } else {
      console.error(err);
    }
    process.exit(1);
  });
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

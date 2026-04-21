let messaging = null;

export async function initFirebaseAdmin() {
  const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credPath) {
    console.warn('Push: GOOGLE_APPLICATION_CREDENTIALS not set; FCM disabled');
    return null;
  }
  try {
    const { default: admin } = await import('firebase-admin');
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
    }
    messaging = admin.messaging();
    console.log('Firebase Admin initialized');
    return messaging;
  } catch (e) {
    console.warn('Firebase Admin init failed:', e.message);
    return null;
  }
}

export function getMessaging() {
  return messaging;
}

import { getMessaging } from '../config/firebase.js';

export async function sendPushToUser(fcmTokens, title, body, data = {}) {
  const messaging = getMessaging();
  if (!messaging || !fcmTokens?.length) return { sent: 0 };

  const payloadData = Object.fromEntries(
    Object.entries(data).map(([k, v]) => [k, String(v)])
  );

  let sent = 0;
  for (const token of fcmTokens) {
    try {
      await messaging.send({
        token,
        notification: { title, body },
        data: payloadData,
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
      });
      sent += 1;
    } catch (e) {
      console.warn('FCM send failed for token:', e.message);
    }
  }
  return { sent };
}

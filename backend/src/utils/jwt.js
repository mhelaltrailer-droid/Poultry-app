import jwt from 'jsonwebtoken';

const secret = () => {
  const s = process.env.JWT_SECRET;
  if (!s) throw new Error('JWT_SECRET is required');
  return s;
};

export function signCustomerToken(payload) {
  return jwt.sign(
    { sub: payload.userId, role: 'customer', phone: payload.phone },
    secret(),
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

/** Staff dashboard JWT (app_admin, ops_admin, or legacy admin). */
export function signStaffToken(payload) {
  return jwt.sign(
    { sub: payload.userId, role: payload.role },
    secret(),
    { expiresIn: process.env.ADMIN_JWT_EXPIRES_IN || '1d' }
  );
}

/** @deprecated use signStaffToken */
export function signAdminToken(payload) {
  return signStaffToken({ userId: payload.userId, role: 'admin' });
}

export function verifyToken(token) {
  return jwt.verify(token, secret());
}

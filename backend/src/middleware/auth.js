import { verifyToken } from '../utils/jwt.js';

export function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication required' });
  }
  try {
    const decoded = verifyToken(header.slice(7));
    req.user = { id: decoded.sub, role: decoded.role, phone: decoded.phone };
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

export function requireCustomer(req, res, next) {
  if (req.user?.role !== 'customer') {
    return res.status(403).json({ message: 'Customer access only' });
  }
  next();
}

const staffRoles = new Set(['admin', 'app_admin', 'ops_admin']);

export function requireAdmin(req, res, next) {
  if (!staffRoles.has(req.user?.role)) {
    return res.status(403).json({ message: 'Admin access only' });
  }
  next();
}

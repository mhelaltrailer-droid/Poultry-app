import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { Order } from '../../models/Order.js';
import { User } from '../../models/User.js';
import { sendPushToUser } from '../../services/notification.service.js';

const router = Router();

const STATUSES = ['pending', 'confirmed', 'preparing', 'on_the_way', 'delivered', 'cancelled'];

router.get('/', async (req, res, next) => {
  try {
    const { status } = req.query;
    const filter = {};
    if (status && STATUSES.includes(status)) filter.status = status;
    const orders = await Order.find(filter)
      .populate('customerId', 'phone name email')
      .sort({ createdAt: -1 })
      .lean();
    res.json(orders);
  } catch (e) {
    next(e);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('customerId', 'phone name email addresses')
      .lean();
    if (!order) return res.status(404).json({ message: 'Not found' });
    res.json(order);
  } catch (e) {
    next(e);
  }
});

router.patch(
  '/:id/status',
  body('status').isIn(STATUSES),
  body('cancellationReason').optional().isString().trim(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const nextStatus = req.body.status;
      const cancellationReason = String(req.body.cancellationReason ?? '').trim();
      if (nextStatus === 'cancelled' && cancellationReason.isEmpty) {
        return res.status(400).json({ message: 'Cancellation reason is required' });
      }
      const order = await Order.findByIdAndUpdate(
        req.params.id,
        {
          status: nextStatus,
          cancellationReason: nextStatus === 'cancelled' ? cancellationReason : '',
        },
        { new: true }
      );
      if (!order) return res.status(404).json({ message: 'Not found' });

      const user = await User.findById(order.customerId);
      const labels = {
        pending: 'Pending',
        confirmed: 'Confirmed',
        preparing: 'Preparing',
        on_the_way: 'On the way',
        delivered: 'Delivered',
        cancelled: 'Cancelled',
      };
      await sendPushToUser(
        user?.fcmTokens || [],
        'Order update',
        `Order ${order.orderNumber} is now: ${labels[order.status]}`,
        { orderId: order._id.toString(), type: 'order_status', status: order.status }
      );

      res.json(order);
    } catch (e) {
      next(e);
    }
  }
);

router.patch(
  '/:id/delivery',
  body('assignedDelivery').isString().trim().notEmpty(),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }
      const order = await Order.findByIdAndUpdate(
        req.params.id,
        { assignedDelivery: req.body.assignedDelivery },
        { new: true }
      );
      if (!order) return res.status(404).json({ message: 'Not found' });
      res.json(order);
    } catch (e) {
      next(e);
    }
  }
);

export default router;

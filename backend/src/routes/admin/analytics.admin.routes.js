import { Router } from 'express';
import { Order } from '../../models/Order.js';
import { User } from '../../models/User.js';

const router = Router();

function parseRange(req) {
  const now = new Date();
  const to = req.query.to ? new Date(`${req.query.to}T23:59:59.999Z`) : now;
  const from = req.query.from
    ? new Date(`${req.query.from}T00:00:00.000Z`)
    : new Date(to.getTime() - 29 * 24 * 60 * 60 * 1000);
  return { from, to };
}

function rangeMatch(createdAtPath = '$createdAt', from, to) {
  return {
    $expr: {
      $and: [
        { $gte: [createdAtPath, from] },
        { $lte: [createdAtPath, to] },
      ],
    },
  };
}

router.get('/summary', async (req, res, next) => {
  try {
    const [agg] = await Order.aggregate([
      {
        $facet: {
          revenue: [
            { $match: { status: { $ne: 'cancelled' } } },
            { $group: { _id: null, total: { $sum: '$total' } } },
          ],
          byStatus: [{ $group: { _id: '$status', count: { $sum: 1 } } }],
          recentOrders: [
            { $sort: { createdAt: -1 } },
            { $limit: 10 },
            {
              $project: {
                orderNumber: 1,
                status: 1,
                total: 1,
                createdAt: 1,
              },
            },
          ],
        },
      },
    ]);

    const totalRevenue = agg.revenue[0]?.total ?? 0;
    const ordersByStatus = Object.fromEntries(
      (agg.byStatus || []).map((x) => [x._id, x.count])
    );

    res.json({
      totalRevenue,
      ordersByStatus,
      recentOrders: agg.recentOrders || [],
    });
  } catch (e) {
    next(e);
  }
});

router.get('/sales', async (req, res, next) => {
  try {
    const { from, to } = parseRange(req);
    const match = {
      status: { $ne: 'cancelled' },
      createdAt: { $gte: from, $lte: to },
    };

    const [agg] = await Order.aggregate([
      { $match: match },
      {
        $facet: {
          totalSales: [{ $group: { _id: null, value: { $sum: '$total' } } }],
          topDay: [
            {
              $group: {
                _id: {
                  y: { $year: '$createdAt' },
                  m: { $month: '$createdAt' },
                  d: { $dayOfMonth: '$createdAt' },
                },
                sales: { $sum: '$total' },
              },
            },
            { $sort: { sales: -1 } },
            { $limit: 1 },
          ],
          avgOrder: [{ $group: { _id: null, value: { $avg: '$total' } } }],
          topDistrict: [
            {
              $group: {
                _id: { $ifNull: ['$deliveryAddress.city', '-'] },
                count: { $sum: 1 },
              },
            },
            { $sort: { count: -1 } },
            { $limit: 1 },
          ],
        },
      },
    ]);

    const day = agg?.topDay?.[0]?._id;
    const topDayLabel = day
      ? `${day.y}-${String(day.m).padStart(2, '0')}-${String(day.d).padStart(2, '0')}`
      : '-';
    res.json({
      from,
      to,
      totalSales: agg?.totalSales?.[0]?.value ?? 0,
      topDay: {
        day: topDayLabel,
        sales: agg?.topDay?.[0]?.sales ?? 0,
      },
      averageOrder: agg?.avgOrder?.[0]?.value ?? 0,
      topDistrict: {
        district: agg?.topDistrict?.[0]?._id ?? '-',
        count: agg?.topDistrict?.[0]?.count ?? 0,
      },
    });
  } catch (e) {
    next(e);
  }
});

router.get('/products', async (req, res, next) => {
  try {
    const { from, to } = parseRange(req);
    const rows = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: from, $lte: to },
          status: { $ne: 'cancelled' },
        },
      },
      { $unwind: '$items' },
      {
        $group: {
          _id: '$items.name',
          quantity: { $sum: '$items.quantity' },
        },
      },
      { $sort: { quantity: -1 } },
    ]);
    res.json({
      from,
      to,
      items: rows.map((r) => ({ name: r._id || '-', quantity: r.quantity || 0 })),
    });
  } catch (e) {
    next(e);
  }
});

router.get('/customers', async (req, res, next) => {
  try {
    const { from, to } = parseRange(req);
    const activeCustomers = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: from, $lte: to },
          status: { $ne: 'cancelled' },
        },
      },
      {
        $addFields: {
          customerKey: {
            $cond: [
              { $ifNull: ['$customerId', false] },
              { $toString: '$customerId' },
              { $concat: ['guest:', { $ifNull: ['$guestPhone', ''] }] },
            ],
          },
          customerName: {
            $cond: [
              { $ifNull: ['$guestName', false] },
              '$guestName',
              'Customer',
            ],
          },
        },
      },
      {
        $group: {
          _id: '$customerKey',
          name: { $first: '$customerName' },
          orderCount: { $sum: 1 },
          totalAmount: { $sum: '$total' },
          lastOrderAt: { $max: '$createdAt' },
        },
      },
    ]);

    const topByOrders = [...activeCustomers]
      .sort((a, b) => b.orderCount - a.orderCount)
      .slice(0, 10)
      .map((x) => ({ name: x.name || x._id, orderCount: x.orderCount || 0 }));
    const topByAmount = [...activeCustomers]
      .sort((a, b) => b.totalAmount - a.totalAmount)
      .slice(0, 10)
      .map((x) => ({ name: x.name || x._id, totalAmount: x.totalAmount || 0 }));

    const threshold = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const inactiveOver30Days = activeCustomers.filter(
      (x) => !x.lastOrderAt || new Date(x.lastOrderAt) < threshold
    ).length;
    const newCustomersCount = await User.countDocuments({
      role: 'customer',
      createdAt: { $gte: from, $lte: to },
    });

    res.json({
      from,
      to,
      topByOrders,
      topByAmount,
      inactiveOver30Days,
      newCustomersCount,
    });
  } catch (e) {
    next(e);
  }
});

router.get('/orders', async (req, res, next) => {
  try {
    const { from, to } = parseRange(req);
    const [agg] = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: from, $lte: to },
        },
      },
      {
        $facet: {
          total: [{ $count: 'count' }],
          cancelled: [
            { $match: { status: 'cancelled' } },
            { $count: 'count' },
          ],
          cancelReasons: [
            { $match: { status: 'cancelled' } },
            {
              $group: {
                _id: {
                  $cond: [
                    { $gt: [{ $strLenCP: { $ifNull: ['$cancellationReason', ''] } }, 0] },
                    '$cancellationReason',
                    '(No reason)',
                  ],
                },
                count: { $sum: 1 },
              },
            },
            { $sort: { count: -1 } },
          ],
          byDistrict: [
            {
              $group: {
                _id: { $ifNull: ['$deliveryAddress.city', '-'] },
                count: { $sum: 1 },
              },
            },
            { $sort: { count: -1 } },
          ],
        },
      },
    ]);

    res.json({
      from,
      to,
      totalOrders: agg?.total?.[0]?.count ?? 0,
      cancelledOrders: agg?.cancelled?.[0]?.count ?? 0,
      cancellationReasons: (agg?.cancelReasons ?? []).map((x) => ({
        reason: x._id,
        count: x.count,
      })),
      byDistrict: (agg?.byDistrict ?? []).map((x) => ({
        district: x._id,
        count: x.count,
      })),
    });
  } catch (e) {
    next(e);
  }
});

export default router;

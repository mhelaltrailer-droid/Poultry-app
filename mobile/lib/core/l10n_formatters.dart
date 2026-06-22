import '../l10n/app_localizations.dart';

String localizedOrderStatus(AppLocalizations l, String status) {
  switch (status) {
    case 'confirmed':
      return l.orderStatusConfirmed;
    case 'preparing':
      return l.orderStatusPreparing;
    case 'on_the_way':
      return l.orderStatusOnTheWay;
    case 'delivered':
      return l.orderStatusDelivered;
    case 'cancelled':
      return l.orderStatusCancelled;
    default:
      return l.orderStatusPending;
  }
}

String localizedAdminRole(AppLocalizations l, String r) {
  switch (r) {
    case 'customer':
      return l.roleCustomer;
    case 'app_admin':
      return l.roleAppAdmin;
    case 'ops_admin':
      return l.roleOpsAdmin;
    case 'admin':
      return l.roleAdminLegacy;
    default:
      return r;
  }
}

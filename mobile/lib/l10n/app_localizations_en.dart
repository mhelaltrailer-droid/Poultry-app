// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DAY TO DAY';

  @override
  String get changeLanguage => 'Switch language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get edit => 'Edit';

  @override
  String get logout => 'Log out';

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeUserName(String name) {
    return 'Welcome, $name';
  }

  @override
  String get startShopping => 'Start shopping';

  @override
  String get shopWithPrefilledContact => 'Shop with contact pre-filled';

  @override
  String get orDivider => 'OR';

  @override
  String get login => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get signUpComingSoonMessage =>
      'Account registration will be available soon. You can use Start shopping now, or log in if you already have an account.';

  @override
  String get loginSheetTitle => 'Log in';

  @override
  String get phone => 'Phone';

  @override
  String get password => 'Password';

  @override
  String get phoneHint => '01111989094';

  @override
  String get navShop => 'Shop';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navYou => 'You';

  @override
  String couldNotLoadProducts(String error) {
    return 'Could not load products.\nCheck API URL and backend.\n$error';
  }

  @override
  String get noProductsYet => 'No products yet.';

  @override
  String get shopSearchHint => 'Search products';

  @override
  String get shopSearchNoResults =>
      'No close matches. Try another spelling or a shorter word.';

  @override
  String get shopSuggestionsTitle => 'Suggestions';

  @override
  String get productTitle => 'Product';

  @override
  String productMetaLine(
    String price,
    String weight,
    String stock,
    String max,
  ) {
    return '$price · $weight · Available $stock · Max/order $max';
  }

  @override
  String get premiumPoultryDescription => 'Premium poultry.';

  @override
  String get quantity => 'Quantity';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get addedToCartSnack => 'Added to cart';

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get checkout => 'Checkout';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get yourDetails => 'Your details';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get deliveryTitle => 'Delivery';

  @override
  String get addressLine1 => 'Address (detail)';

  @override
  String get cityDistrict => 'City / district';

  @override
  String get promoOptional => 'Promo code (optional)';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String totalAmount(String amount) {
    return 'Total: $amount';
  }

  @override
  String get errNamePhoneRequired => 'Name and phone are required.';

  @override
  String get errAddressRequired =>
      'Address and city are required for delivery.';

  @override
  String get confirmOrder => 'Place order';

  @override
  String get orderPlacedTitle => 'Order placed';

  @override
  String orderThankYou(String orderNumber, String status) {
    return 'Thank you. Order $orderNumber — status: $status.\n\nYou can create an account later when registration is available to save your orders and details.';
  }

  @override
  String get addressLabelHome => 'Home';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusOnTheWay => 'On the way';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersHistoryTitle => 'Order history';

  @override
  String get ordersExplainer =>
      'Orders linked to your phone number on this device. Tap an order to review it or reorder.';

  @override
  String get reorder => 'Reorder';

  @override
  String get reorderTitle => 'Reorder';

  @override
  String get reorderHint =>
      'Review items from this order. Adjust quantities, then add to your cart before checkout.';

  @override
  String get reorderItemsTitle => 'Items';

  @override
  String get reorderAddToCart => 'Add to cart';

  @override
  String get reorderAddedToCart => 'Items added to cart';

  @override
  String get reorderEmpty =>
      'No items from this order can be added to the cart.';

  @override
  String reorderUnavailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items from this order are no longer available.',
      one: '1 item from this order is no longer available.',
    );
    return '$_temp0';
  }

  @override
  String get reorderPreviousSlot => 'Previous delivery slot';

  @override
  String get reorderReplaceCartTitle => 'Cart is not empty';

  @override
  String get reorderReplaceCartBody =>
      'Replace current cart items or add these items to what you already have?';

  @override
  String get reorderReplaceCart => 'Replace cart';

  @override
  String get reorderMergeCart => 'Add to cart';

  @override
  String get orderDetailTitle => 'Order details';

  @override
  String get orderDeliverySlot => 'Delivery slot';

  @override
  String get orderDeliveryAddress => 'Address';

  @override
  String get orderDeliveryFee => 'Delivery fee';

  @override
  String get orderDiscount => 'Discount';

  @override
  String get orderTotal => 'Total';

  @override
  String orderPlacedAt(String date) {
    return 'Placed $date';
  }

  @override
  String get orderCancelTitle => 'Cancel order?';

  @override
  String get orderCancelConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get orderCancelAction => 'Cancel order';

  @override
  String get orderCancelledSnack => 'Order cancelled';

  @override
  String get orderCancelReason => 'Reason';

  @override
  String get orderCancelSupportHint =>
      'This order is already being prepared. To cancel, please contact support via WhatsApp.';

  @override
  String get orderContactSupport => 'Contact support on WhatsApp';

  @override
  String orderSupportWhatsAppMessage(String orderNumber) {
    return 'Hello, I need help with my order $orderNumber.';
  }

  @override
  String orderTrackerYouAreHere(String status) {
    return 'Current step: $status';
  }

  @override
  String get orderTrackerAutoRefresh =>
      'Status updates automatically every 45 seconds';

  @override
  String get profilePhonesTitle => 'Phone numbers';

  @override
  String get profilePhonesHint => 'Choose the default number used at checkout.';

  @override
  String get profileAddPhone => 'Add phone number';

  @override
  String get profilePhoneLabel => 'Label';

  @override
  String get profileAddressesTitle => 'Addresses';

  @override
  String get profileAddressesHint =>
      'Save multiple addresses and pick one at checkout.';

  @override
  String get profileAddAddress => 'Add address';

  @override
  String get profileAddressLabel => 'Address label';

  @override
  String get profileDistrict => 'District';

  @override
  String get profileAddressDetails => 'Address details';

  @override
  String get profileSelectPhone => 'Delivery phone';

  @override
  String get profileSelectAddress => 'Delivery address';

  @override
  String get profileEmptyHint =>
      'Complete sign-up first to manage your contact details.';

  @override
  String get profileEmptyCheckoutHint =>
      'No profile data found. Please complete Sign Up first.';

  @override
  String get lastOrderOnDevice => 'Last order on this device';

  @override
  String get profileTitle => 'My profile';

  @override
  String get contactSectionTitle => 'Contact details';

  @override
  String get contactSectionHint =>
      'Used at checkout and saved locally on your device.';

  @override
  String get labelName => 'Name';

  @override
  String get savedSnack => 'Saved';

  @override
  String get permanentAccountTitle => 'Permanent account';

  @override
  String get permanentAccountHint =>
      'When sign-up is available you can link your orders to one account. Until then, shopping and the cart stay on this device.';

  @override
  String get backToStartTitle => 'Back to start?';

  @override
  String get backToStartBody => 'Your cart will stay saved on this device.';

  @override
  String get backToStartButton => 'Back to start screen';

  @override
  String get staffNoDashboardTitle => 'DAY TO DAY';

  @override
  String get staffNoDashboardMessage =>
      'The in-app dashboard is only available to the app administrator.';

  @override
  String get staffLogout => 'Log out';

  @override
  String get adminTitleUsers => 'App users';

  @override
  String get adminTitleCustomers => 'Customers';

  @override
  String get adminTitleProducts => 'Products';

  @override
  String get adminTitleStock => 'Stock';

  @override
  String get adminNavUsers => 'Users';

  @override
  String get adminNavCustomers => 'Customers';

  @override
  String get adminNavProducts => 'Products';

  @override
  String get adminNavStock => 'Stock';

  @override
  String get adminDashboardDrawer => 'Dashboard';

  @override
  String get adminLogout => 'Log out';

  @override
  String get adminNewUser => 'New user';

  @override
  String get adminEditUser => 'Edit user';

  @override
  String get adminNewCustomer => 'New customer';

  @override
  String get adminEditCustomer => 'Edit customer';

  @override
  String get adminNewProduct => 'New product';

  @override
  String get adminEditProduct => 'Edit product';

  @override
  String get adminDeleteUserTitle => 'Delete user?';

  @override
  String get adminDeleteCustomerTitle => 'Delete customer?';

  @override
  String get adminDeleteProductTitle => 'Delete product?';

  @override
  String get adminEnterPasswordNewUser => 'Enter a password for the new user';

  @override
  String get adminEnterPasswordNewCustomer =>
      'Enter a password for the new customer';

  @override
  String get adminDistrict => 'District';

  @override
  String get adminAddressDetail => 'Address detail';

  @override
  String get adminPassword => 'Password';

  @override
  String get adminPasswordOptional => 'Password (optional)';

  @override
  String get adminPasswordOptionalUnchanged =>
      'Password (leave blank if unchanged)';

  @override
  String get adminRole => 'Role';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleAppAdmin => 'App admin';

  @override
  String get roleOpsAdmin => 'Operations admin';

  @override
  String get roleAdminLegacy => 'Admin (legacy)';

  @override
  String get adminProductName => 'Product name (default & slug)';

  @override
  String get adminDescription => 'Description (default)';

  @override
  String get adminNameEnglish => 'Name — English';

  @override
  String get adminNameArabic => 'Name — Arabic';

  @override
  String get adminDescriptionEnglish => 'Description — English';

  @override
  String get adminDescriptionArabic => 'Description — Arabic';

  @override
  String get adminPrice => 'Price';

  @override
  String get adminSalePriceHint =>
      'Sale price (optional, leave empty to remove discount)';

  @override
  String get adminWeightQty => 'Weight / quantity';

  @override
  String get adminWeightUnit => 'Weight unit';

  @override
  String get adminStock => 'Available stock';

  @override
  String get adminMaxOrderQty => 'Max quantity per order';

  @override
  String get adminCategory => 'Category';

  @override
  String get adminActive => 'Active';

  @override
  String get adminYes => 'Yes';

  @override
  String get adminNo => 'No';

  @override
  String get adminImageUrlHint => 'Image URL (add multiple times)';

  @override
  String get adminAddImageUrlButton => 'Add image URL';

  @override
  String get adminCheckNumbers => 'Check the numbers';

  @override
  String get adminInvalidSalePrice => 'Invalid sale price';

  @override
  String get adminStockUpdated => 'Quantities updated';

  @override
  String get adminEnterIntegers => 'Enter valid integers';

  @override
  String adminStockDialogTitle(String name) {
    return 'Stock: $name';
  }

  @override
  String productCardSubtitleSale(String price, String sale, String stock) {
    return 'Price: $price · Sale: $sale · Stock $stock';
  }

  @override
  String productCardSubtitle(String price, String stock) {
    return 'Price: $price · Stock $stock';
  }

  @override
  String get adminAddUser => 'Add user';

  @override
  String get adminAddCustomer => 'Add customer';

  @override
  String get adminAddProduct => 'Add product';

  @override
  String get adminCustomerDistrictTitle => 'District';

  @override
  String get adminCustomerAddressTitle => 'Address';

  @override
  String stockCardSubtitle(String stock, String max) {
    return 'Available: $stock · Max order: $max';
  }
}

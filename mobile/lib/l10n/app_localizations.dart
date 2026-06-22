import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DAY TO DAY'**
  String get appTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get changeLanguage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeUserName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUserName(String name);

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get startShopping;

  /// No description provided for @shopWithPrefilledContact.
  ///
  /// In en, this message translates to:
  /// **'Shop with contact pre-filled'**
  String get shopWithPrefilledContact;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @signUpComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Account registration will be available soon. You can use Start shopping now, or log in if you already have an account.'**
  String get signUpComingSoonMessage;

  /// No description provided for @loginSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSheetTitle;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'01111989094'**
  String get phoneHint;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @couldNotLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Could not load products.\nCheck API URL and backend.\n{error}'**
  String couldNotLoadProducts(String error);

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet.'**
  String get noProductsYet;

  /// No description provided for @shopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get shopSearchHint;

  /// No description provided for @shopSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No close matches. Try another spelling or a shorter word.'**
  String get shopSearchNoResults;

  /// No description provided for @shopSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get shopSuggestionsTitle;

  /// No description provided for @productTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productTitle;

  /// No description provided for @productMetaLine.
  ///
  /// In en, this message translates to:
  /// **'{price} · {weight} · Available {stock} · Max/order {max}'**
  String productMetaLine(String price, String weight, String stock, String max);

  /// No description provided for @premiumPoultryDescription.
  ///
  /// In en, this message translates to:
  /// **'Premium poultry.'**
  String get premiumPoultryDescription;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @addedToCartSnack.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCartSnack;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @deliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryTitle;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address (detail)'**
  String get addressLine1;

  /// No description provided for @cityDistrict.
  ///
  /// In en, this message translates to:
  /// **'City / district'**
  String get cityDistrict;

  /// No description provided for @promoOptional.
  ///
  /// In en, this message translates to:
  /// **'Promo code (optional)'**
  String get promoOptional;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String totalAmount(String amount);

  /// No description provided for @errNamePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and phone are required.'**
  String get errNamePhoneRequired;

  /// No description provided for @errAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address and city are required for delivery.'**
  String get errAddressRequired;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get confirmOrder;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlacedTitle;

  /// No description provided for @orderThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Order {orderNumber} — status: {status}.\n\nYou can create an account later when registration is available to save your orders and details.'**
  String orderThankYou(String orderNumber, String status);

  /// No description provided for @addressLabelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressLabelHome;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get orderStatusOnTheWay;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get ordersHistoryTitle;

  /// No description provided for @ordersExplainer.
  ///
  /// In en, this message translates to:
  /// **'Orders linked to your phone number on this device. Tap an order to review it or reorder.'**
  String get ordersExplainer;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @reorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderTitle;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Review items from this order. Adjust quantities, then add to your cart before checkout.'**
  String get reorderHint;

  /// No description provided for @reorderItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get reorderItemsTitle;

  /// No description provided for @reorderAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get reorderAddToCart;

  /// No description provided for @reorderAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Items added to cart'**
  String get reorderAddedToCart;

  /// No description provided for @reorderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items from this order can be added to the cart.'**
  String get reorderEmpty;

  /// No description provided for @reorderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item from this order is no longer available.} other{{count} items from this order are no longer available.}}'**
  String reorderUnavailable(int count);

  /// No description provided for @reorderPreviousSlot.
  ///
  /// In en, this message translates to:
  /// **'Previous delivery slot'**
  String get reorderPreviousSlot;

  /// No description provided for @reorderReplaceCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart is not empty'**
  String get reorderReplaceCartTitle;

  /// No description provided for @reorderReplaceCartBody.
  ///
  /// In en, this message translates to:
  /// **'Replace current cart items or add these items to what you already have?'**
  String get reorderReplaceCartBody;

  /// No description provided for @reorderReplaceCart.
  ///
  /// In en, this message translates to:
  /// **'Replace cart'**
  String get reorderReplaceCart;

  /// No description provided for @reorderMergeCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get reorderMergeCart;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailTitle;

  /// No description provided for @orderDeliverySlot.
  ///
  /// In en, this message translates to:
  /// **'Delivery slot'**
  String get orderDeliverySlot;

  /// No description provided for @orderDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get orderDeliveryAddress;

  /// No description provided for @orderDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get orderDeliveryFee;

  /// No description provided for @orderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get orderDiscount;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTotal;

  /// No description provided for @orderPlacedAt.
  ///
  /// In en, this message translates to:
  /// **'Placed {date}'**
  String orderPlacedAt(String date);

  /// No description provided for @orderCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order?'**
  String get orderCancelTitle;

  /// No description provided for @orderCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get orderCancelConfirm;

  /// No description provided for @orderCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancelAction;

  /// No description provided for @orderCancelledSnack.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelledSnack;

  /// No description provided for @orderCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get orderCancelReason;

  /// No description provided for @orderCancelSupportHint.
  ///
  /// In en, this message translates to:
  /// **'This order is already being prepared. To cancel, please contact support via WhatsApp.'**
  String get orderCancelSupportHint;

  /// No description provided for @orderContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support on WhatsApp'**
  String get orderContactSupport;

  /// No description provided for @orderSupportWhatsAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, I need help with my order {orderNumber}.'**
  String orderSupportWhatsAppMessage(String orderNumber);

  /// No description provided for @orderTrackerYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'Current step: {status}'**
  String orderTrackerYouAreHere(String status);

  /// No description provided for @orderTrackerAutoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Status updates automatically every 45 seconds'**
  String get orderTrackerAutoRefresh;

  /// No description provided for @profilePhonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers'**
  String get profilePhonesTitle;

  /// No description provided for @profilePhonesHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the default number used at checkout.'**
  String get profilePhonesHint;

  /// No description provided for @profileAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get profileAddPhone;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get profilePhoneLabel;

  /// No description provided for @profileAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get profileAddressesTitle;

  /// No description provided for @profileAddressesHint.
  ///
  /// In en, this message translates to:
  /// **'Save multiple addresses and pick one at checkout.'**
  String get profileAddressesHint;

  /// No description provided for @profileAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get profileAddAddress;

  /// No description provided for @profileAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address label'**
  String get profileAddressLabel;

  /// No description provided for @profileDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get profileDistrict;

  /// No description provided for @profileAddressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address details'**
  String get profileAddressDetails;

  /// No description provided for @profileSelectPhone.
  ///
  /// In en, this message translates to:
  /// **'Delivery phone'**
  String get profileSelectPhone;

  /// No description provided for @profileSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get profileSelectAddress;

  /// No description provided for @profileEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Complete sign-up first to manage your contact details.'**
  String get profileEmptyHint;

  /// No description provided for @profileEmptyCheckoutHint.
  ///
  /// In en, this message translates to:
  /// **'No profile data found. Please complete Sign Up first.'**
  String get profileEmptyCheckoutHint;

  /// No description provided for @lastOrderOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Last order on this device'**
  String get lastOrderOnDevice;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profileTitle;

  /// No description provided for @contactSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get contactSectionTitle;

  /// No description provided for @contactSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Used at checkout and saved locally on your device.'**
  String get contactSectionHint;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @savedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSnack;

  /// No description provided for @permanentAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent account'**
  String get permanentAccountTitle;

  /// No description provided for @permanentAccountHint.
  ///
  /// In en, this message translates to:
  /// **'When sign-up is available you can link your orders to one account. Until then, shopping and the cart stay on this device.'**
  String get permanentAccountHint;

  /// No description provided for @backToStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Back to start?'**
  String get backToStartTitle;

  /// No description provided for @backToStartBody.
  ///
  /// In en, this message translates to:
  /// **'Your cart will stay saved on this device.'**
  String get backToStartBody;

  /// No description provided for @backToStartButton.
  ///
  /// In en, this message translates to:
  /// **'Back to start screen'**
  String get backToStartButton;

  /// No description provided for @staffNoDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'DAY TO DAY'**
  String get staffNoDashboardTitle;

  /// No description provided for @staffNoDashboardMessage.
  ///
  /// In en, this message translates to:
  /// **'The in-app dashboard is only available to the app administrator.'**
  String get staffNoDashboardMessage;

  /// No description provided for @staffLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get staffLogout;

  /// No description provided for @adminTitleUsers.
  ///
  /// In en, this message translates to:
  /// **'App users'**
  String get adminTitleUsers;

  /// No description provided for @adminTitleCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get adminTitleCustomers;

  /// No description provided for @adminTitleProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminTitleProducts;

  /// No description provided for @adminTitleStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get adminTitleStock;

  /// No description provided for @adminNavUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminNavUsers;

  /// No description provided for @adminNavCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get adminNavCustomers;

  /// No description provided for @adminNavProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminNavProducts;

  /// No description provided for @adminNavStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get adminNavStock;

  /// No description provided for @adminDashboardDrawer.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboardDrawer;

  /// No description provided for @adminLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get adminLogout;

  /// No description provided for @adminNewUser.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get adminNewUser;

  /// No description provided for @adminEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get adminEditUser;

  /// No description provided for @adminNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get adminNewCustomer;

  /// No description provided for @adminEditCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get adminEditCustomer;

  /// No description provided for @adminNewProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get adminNewProduct;

  /// No description provided for @adminEditProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get adminEditProduct;

  /// No description provided for @adminDeleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete user?'**
  String get adminDeleteUserTitle;

  /// No description provided for @adminDeleteCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete customer?'**
  String get adminDeleteCustomerTitle;

  /// No description provided for @adminDeleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get adminDeleteProductTitle;

  /// No description provided for @adminEnterPasswordNewUser.
  ///
  /// In en, this message translates to:
  /// **'Enter a password for the new user'**
  String get adminEnterPasswordNewUser;

  /// No description provided for @adminEnterPasswordNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Enter a password for the new customer'**
  String get adminEnterPasswordNewCustomer;

  /// No description provided for @adminDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get adminDistrict;

  /// No description provided for @adminAddressDetail.
  ///
  /// In en, this message translates to:
  /// **'Address detail'**
  String get adminAddressDetail;

  /// No description provided for @adminPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPassword;

  /// No description provided for @adminPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get adminPasswordOptional;

  /// No description provided for @adminPasswordOptionalUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Password (leave blank if unchanged)'**
  String get adminPasswordOptionalUnchanged;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRole;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @roleAppAdmin.
  ///
  /// In en, this message translates to:
  /// **'App admin'**
  String get roleAppAdmin;

  /// No description provided for @roleOpsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Operations admin'**
  String get roleOpsAdmin;

  /// No description provided for @roleAdminLegacy.
  ///
  /// In en, this message translates to:
  /// **'Admin (legacy)'**
  String get roleAdminLegacy;

  /// No description provided for @adminProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name (default & slug)'**
  String get adminProductName;

  /// No description provided for @adminDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (default)'**
  String get adminDescription;

  /// No description provided for @adminNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name — English'**
  String get adminNameEnglish;

  /// No description provided for @adminNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Name — Arabic'**
  String get adminNameArabic;

  /// No description provided for @adminDescriptionEnglish.
  ///
  /// In en, this message translates to:
  /// **'Description — English'**
  String get adminDescriptionEnglish;

  /// No description provided for @adminDescriptionArabic.
  ///
  /// In en, this message translates to:
  /// **'Description — Arabic'**
  String get adminDescriptionArabic;

  /// No description provided for @adminPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminPrice;

  /// No description provided for @adminSalePriceHint.
  ///
  /// In en, this message translates to:
  /// **'Sale price (optional, leave empty to remove discount)'**
  String get adminSalePriceHint;

  /// No description provided for @adminWeightQty.
  ///
  /// In en, this message translates to:
  /// **'Weight / quantity'**
  String get adminWeightQty;

  /// No description provided for @adminWeightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get adminWeightUnit;

  /// No description provided for @adminStock.
  ///
  /// In en, this message translates to:
  /// **'Available stock'**
  String get adminStock;

  /// No description provided for @adminMaxOrderQty.
  ///
  /// In en, this message translates to:
  /// **'Max quantity per order'**
  String get adminMaxOrderQty;

  /// No description provided for @adminCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get adminCategory;

  /// No description provided for @adminActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminActive;

  /// No description provided for @adminYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get adminYes;

  /// No description provided for @adminNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get adminNo;

  /// No description provided for @adminImageUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Image URL (add multiple times)'**
  String get adminImageUrlHint;

  /// No description provided for @adminAddImageUrlButton.
  ///
  /// In en, this message translates to:
  /// **'Add image URL'**
  String get adminAddImageUrlButton;

  /// No description provided for @adminCheckNumbers.
  ///
  /// In en, this message translates to:
  /// **'Check the numbers'**
  String get adminCheckNumbers;

  /// No description provided for @adminInvalidSalePrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid sale price'**
  String get adminInvalidSalePrice;

  /// No description provided for @adminStockUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quantities updated'**
  String get adminStockUpdated;

  /// No description provided for @adminEnterIntegers.
  ///
  /// In en, this message translates to:
  /// **'Enter valid integers'**
  String get adminEnterIntegers;

  /// No description provided for @adminStockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock: {name}'**
  String adminStockDialogTitle(String name);

  /// No description provided for @productCardSubtitleSale.
  ///
  /// In en, this message translates to:
  /// **'Price: {price} · Sale: {sale} · Stock {stock}'**
  String productCardSubtitleSale(String price, String sale, String stock);

  /// No description provided for @productCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Price: {price} · Stock {stock}'**
  String productCardSubtitle(String price, String stock);

  /// No description provided for @adminAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get adminAddUser;

  /// No description provided for @adminAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get adminAddCustomer;

  /// No description provided for @adminAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get adminAddProduct;

  /// No description provided for @adminCustomerDistrictTitle.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get adminCustomerDistrictTitle;

  /// No description provided for @adminCustomerAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adminCustomerAddressTitle;

  /// No description provided for @stockCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available: {stock} · Max order: {max}'**
  String stockCardSubtitle(String stock, String max);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

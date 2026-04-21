// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'DAY TO DAY';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get ok => 'حسناً';

  @override
  String get edit => 'تعديل';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get welcome => 'مرحباً';

  @override
  String welcomeUserName(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String get shopWithPrefilledContact => 'تسوق مع بيانات جاهزة';

  @override
  String get orDivider => 'أو';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signUpComingSoonMessage =>
      'التسجيل لإنشاء حساب سيكون متاحاً قريباً. يمكنك البدء بالتسوق الآن، أو تسجيل الدخول إن كان لديك حساب.';

  @override
  String get loginSheetTitle => 'تسجيل الدخول';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get phoneHint => '01111989094';

  @override
  String get staffWelcomeHint => 'للطاقم: استخدم تسجيل الدخول.';

  @override
  String get navShop => 'المتجر';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navYou => 'حسابي';

  @override
  String couldNotLoadProducts(String error) {
    return 'تعذّر تحميل المنتجات.\nتحقق من عنوان الـ API والخادم.\n$error';
  }

  @override
  String get noProductsYet => 'لا توجد منتجات بعد.';

  @override
  String get shopSearchHint => 'ابحث عن منتج';

  @override
  String get shopSearchNoResults =>
      'لا نتائج قريبة. جرّب كتابة أخرى أو كلمة أقصر.';

  @override
  String get shopSuggestionsTitle => 'اقتراحات';

  @override
  String get productTitle => 'المنتج';

  @override
  String productMetaLine(
    String price,
    String weight,
    String stock,
    String max,
  ) {
    return '$price · $weight · متاح $stock · حد أقصى/طلب $max';
  }

  @override
  String get premiumPoultryDescription => 'دواجن ممتازة.';

  @override
  String get quantity => 'الكمية';

  @override
  String get addToCart => 'أضف للسلة';

  @override
  String get addedToCartSnack => 'تمت الإضافة للسلة';

  @override
  String get cartTitle => 'سلتك';

  @override
  String get cartEmpty => 'السلة فارغة';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get checkoutTitle => 'إتمام الطلب';

  @override
  String get yourDetails => 'بياناتك';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get deliveryTitle => 'التوصيل';

  @override
  String get addressLine1 => 'العنوان (تفصيلي)';

  @override
  String get cityDistrict => 'المدينة / الحي';

  @override
  String get promoOptional => 'كود خصم (اختياري)';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String totalAmount(String amount) {
    return 'المجموع: $amount';
  }

  @override
  String get errNamePhoneRequired => 'الاسم ورقم الهاتف مطلوبان.';

  @override
  String get errAddressRequired => 'العنوان والمدينة مطلوبان للتوصيل.';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get orderPlacedTitle => 'تم الطلب';

  @override
  String orderThankYou(String orderNumber, String status) {
    return 'شكراً لك. رقم الطلب $orderNumber — الحالة: $status.\n\nلاحقاً يمكنك إنشاء حساب عند توفر التسجيل لحفظ طلباتك وبياناتك.';
  }

  @override
  String get addressLabelHome => 'المنزل';

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusPreparing => 'قيد التجهيز';

  @override
  String get orderStatusOnTheWay => 'في الطريق';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get orderStatusCancelled => 'ملغى';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String get ordersHistoryTitle => 'سجل الطلبات';

  @override
  String get ordersExplainer =>
      'الطلبات المرتبطة بحساب مسجّل تظهر هنا عند تفعيل ذلك لاحقاً. تسوقك الحالي يتم بالكامل محلياً على هذا الجهاز.';

  @override
  String get lastOrderOnDevice => 'آخر طلب من هذا الجهاز';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get contactSectionTitle => 'بيانات التواصل';

  @override
  String get contactSectionHint =>
      'تُستخدم عند إتمام الطلب ويُحفظ محلياً على جهازك.';

  @override
  String get labelName => 'الاسم';

  @override
  String get savedSnack => 'تم الحفظ';

  @override
  String get permanentAccountTitle => 'حساب دائم';

  @override
  String get permanentAccountHint =>
      'عند توفر التسجيل يمكنك ربط طلباتك بحساب واحد. إلى ذلك الحين يبقى التسوق والسلة على هذا الجهاز.';

  @override
  String get backToStartTitle => 'العودة للبداية؟';

  @override
  String get backToStartBody => 'ستبقى السلة محفوظة على هذا الجهاز.';

  @override
  String get backToStartButton => 'العودة لشاشة البداية';

  @override
  String get staffNoDashboardTitle => 'DAY TO DAY';

  @override
  String get staffNoDashboardMessage => 'لوحة التحكم متاحة لمسؤول التطبيق فقط.';

  @override
  String get staffLogout => 'تسجيل الخروج';

  @override
  String get adminTitleUsers => 'مستخدمو التطبيق';

  @override
  String get adminTitleCustomers => 'العملاء';

  @override
  String get adminTitleProducts => 'الأصناف';

  @override
  String get adminTitleStock => 'إدارة الكميات';

  @override
  String get adminNavUsers => 'المستخدمون';

  @override
  String get adminNavCustomers => 'العملاء';

  @override
  String get adminNavProducts => 'الأصناف';

  @override
  String get adminNavStock => 'الكميات';

  @override
  String get adminDashboardDrawer => 'لوحة التحكم';

  @override
  String get adminLogout => 'خروج';

  @override
  String get adminNewUser => 'مستخدم جديد';

  @override
  String get adminEditUser => 'تعديل مستخدم';

  @override
  String get adminNewCustomer => 'عميل جديد';

  @override
  String get adminEditCustomer => 'تعديل عميل';

  @override
  String get adminNewProduct => 'صنف جديد';

  @override
  String get adminEditProduct => 'تعديل صنف';

  @override
  String get adminDeleteUserTitle => 'حذف المستخدم؟';

  @override
  String get adminDeleteCustomerTitle => 'حذف العميل؟';

  @override
  String get adminDeleteProductTitle => 'حذف الصنف؟';

  @override
  String get adminEnterPasswordNewUser => 'أدخل كلمة مرور للمستخدم الجديد';

  @override
  String get adminEnterPasswordNewCustomer => 'أدخل كلمة مرور للعميل الجديد';

  @override
  String get adminDistrict => 'الحي';

  @override
  String get adminAddressDetail => 'العنوان التفصيلي';

  @override
  String get adminPassword => 'كلمة المرور';

  @override
  String get adminPasswordOptional => 'كلمة المرور (اختياري)';

  @override
  String get adminPasswordOptionalUnchanged =>
      'كلمة المرور (اتركها فارغة إن لم تتغير)';

  @override
  String get adminRole => 'الصلاحية';

  @override
  String get roleCustomer => 'عميل';

  @override
  String get roleAppAdmin => 'مسؤول التطبيق';

  @override
  String get roleOpsAdmin => 'مسؤول إدارة';

  @override
  String get roleAdminLegacy => 'مسؤول (قديم)';

  @override
  String get adminProductName => 'اسم الصنف (افتراضي والرابط)';

  @override
  String get adminDescription => 'الوصف (افتراضي)';

  @override
  String get adminNameEnglish => 'الاسم — إنجليزي';

  @override
  String get adminNameArabic => 'الاسم — عربي';

  @override
  String get adminDescriptionEnglish => 'الوصف — إنجليزي';

  @override
  String get adminDescriptionArabic => 'الوصف — عربي';

  @override
  String get adminPrice => 'السعر';

  @override
  String get adminSalePriceHint =>
      'السعر بعد الخصم (اختياري، اتركه فارغاً لإلغاء الخصم)';

  @override
  String get adminWeightQty => 'الوزن / الكمية';

  @override
  String get adminWeightUnit => 'وحدة الوزن';

  @override
  String get adminStock => 'الكمية المتاحة';

  @override
  String get adminMaxOrderQty => 'أقصى كمية للطلب في المرة';

  @override
  String get adminCategory => 'التصنيف';

  @override
  String get adminActive => 'نشط';

  @override
  String get adminYes => 'نعم';

  @override
  String get adminNo => 'لا';

  @override
  String get adminImageUrlHint => 'رابط صورة (أضف عدة مرات)';

  @override
  String get adminAddImageUrlButton => 'إضافة رابط الصورة';

  @override
  String get adminCheckNumbers => 'تحقق من الأرقام';

  @override
  String get adminInvalidSalePrice => 'سعر الخصم غير صالح';

  @override
  String get adminStockUpdated => 'تم تحديث الكميات';

  @override
  String get adminEnterIntegers => 'أدخل أرقاماً صحيحة';

  @override
  String adminStockDialogTitle(String name) {
    return 'كميات: $name';
  }

  @override
  String productCardSubtitleSale(String price, String sale, String stock) {
    return 'سعر: $price · بعد الخصم: $sale · مخزون $stock';
  }

  @override
  String productCardSubtitle(String price, String stock) {
    return 'سعر: $price · مخزون $stock';
  }

  @override
  String get adminAddUser => 'إضافة مستخدم';

  @override
  String get adminAddCustomer => 'إضافة عميل';

  @override
  String get adminAddProduct => 'إضافة صنف';

  @override
  String get adminCustomerDistrictTitle => 'الحي';

  @override
  String get adminCustomerAddressTitle => 'العنوان';

  @override
  String stockCardSubtitle(String stock, String max) {
    return 'متاح: $stock · حد الطلب: $max';
  }
}

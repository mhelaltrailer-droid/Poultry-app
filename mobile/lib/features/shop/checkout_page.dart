import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../auth/auth_controller.dart';
import '../auth/customer_profile.dart';
import '../auth/customer_profile_local_service.dart';
import '../cart/cart_controller.dart';
import '../orders/orders_page.dart';
import 'shop_repository.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const double _deliveryFee = 30;
  final _notes = TextEditingController();
  final _profileService = CustomerProfileLocalService();
  bool _busy = false;
  String? _error;
  CustomerProfile? _profile;
  bool _slotsLoading = true;
  List<DeliverySlot> _slots = [];
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDeliverySlots();
  }

  Future<void> _loadDeliverySlots() async {
    setState(() {
      _slotsLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<ShopRepository>();
      final slots = await repo.fetchDeliverySlots();
      final visible = slots.where((s) => s.isVisible).toList()
        ..sort((a, b) => a.fromHour.compareTo(b.fromHour));
      String? selected;
      final nowHour = DateTime.now().hour;
      for (final s in visible) {
        if (s.fromHour == nowHour && !s.isFull) {
          selected = s.id;
          break;
        }
      }
      if (selected == null) {
        for (final s in visible) {
          if (!s.isFull) {
            selected = s.id;
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _slots = visible;
        _selectedSlotId = selected;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _slotsLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    final p = await _profileService.load();
    if (!mounted) return;
    if (p != null) {
      setState(() => _profile = p);
      return;
    }

    final auth = context.read<AuthController>();
    final hasAuthProfileBasics = auth.guestName.trim().isNotEmpty &&
        auth.guestPhone.trim().isNotEmpty &&
        auth.guestDistrict.trim().isNotEmpty &&
        auth.guestAddressDetail.trim().isNotEmpty;

    if (!hasAuthProfileBasics) {
      setState(() => _profile = null);
      return;
    }

    final fallback = CustomerProfile(
      name: auth.guestName.trim(),
      familyName: '',
      mobile: auth.guestPhone.trim(),
      city: 'Obour City',
      district: auth.guestDistrict.trim(),
      addressDetails: auth.guestAddressDetail.trim(),
      deliveryNotes: '',
    );
    await _profileService.save(fallback);
    if (!mounted) return;
    setState(() => _profile = fallback);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final profile = _profile;
    if (profile == null) {
      setState(() => _error = l10n.errNamePhoneRequired);
      return;
    }
    if (profile.addressDetails.trim().isEmpty || profile.district.trim().isEmpty) {
      setState(() => _error = l10n.errAddressRequired);
      return;
    }
    if (_selectedSlotId == null || _selectedSlotId!.isEmpty) {
      setState(() => _error = 'Please choose an available delivery time');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    final cart = context.read<CartController>();
    final repo = context.read<ShopRepository>();
    final auth = context.read<AuthController>();
    final localeCode = Localizations.localeOf(context).languageCode;
    final items = cart.lines
        .map(
          (l) => {
            'productId': l.productId,
            'quantity': l.quantity,
          },
        )
        .toList();
    try {
      await auth.setGuestContact(name: profile.name, phone: profile.mobile);
      final order = await repo.placeGuestOrder(
        items: items,
        guestName: profile.name,
        guestPhone: profile.mobile,
        deliveryAddress: {
          'line1': profile.addressDetails,
          'city': profile.district,
          'phone': profile.mobile,
          'label': l10n.addressLabelHome,
        },
        deliveryFee: _deliveryFee,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        locale: localeCode,
        deliverySlotId: _selectedSlotId,
      );
      cart.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final loc = ctx.l10n;
          return AlertDialog(
            title: Text(loc.orderPlacedTitle),
            content: Text(
              localeCode.startsWith('ar')
                  ? 'تم الطلب بنجاح\nرقم الطلب: ${order.orderNumber}'
                  : 'Order placed successfully.\nOrder number: ${order.orderNumber}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(loc.ok),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const OrdersPage()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();
    final profile = _profile;
    final subtotal = cart.subtotal;
    final total = subtotal + _deliveryFee;
    final hasAvailableSlots = _slots.any((s) => !s.isFull);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(l10n.checkoutTitle),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width)),
        children: [
          Text('Customer details', style: GoogleFonts.playfairDisplay(fontSize: 22)),
          SizedBox(height: AppSpacing.sm),
          if (profile == null)
            Text(
              'No profile data found. Please complete Sign Up first.',
              style: const TextStyle(color: Colors.red),
            )
          else
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${profile.name}'),
                    SizedBox(height: AppSpacing.xs),
                    Text('Mobile: ${profile.mobile}'),
                    SizedBox(height: AppSpacing.xs),
                    Text('District: ${profile.district}'),
                    SizedBox(height: AppSpacing.xs),
                    Text('Address Details: ${profile.addressDetails}'),
                  ],
                ),
              ),
            ),
          SizedBox(height: AppSpacing.md),
          Text('Order details', style: GoogleFonts.playfairDisplay(fontSize: 22)),
          SizedBox(height: AppSpacing.sm),
          ...cart.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  title: Text(line.name),
                  subtitle: Text('${line.price.toStringAsFixed(2)} × ${line.quantity}'),
                  leading: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _busy
                        ? null
                        : () => context.read<CartController>().remove(line.productId),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _busy
                            ? null
                            : () => context.read<CartController>().setQuantity(
                                  line.productId,
                                  line.quantity - 1,
                                ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${line.quantity}'),
                      IconButton(
                        onPressed: _busy
                            ? null
                            : () => context.read<CartController>().setQuantity(
                                  line.productId,
                                  line.quantity + 1,
                                ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (cart.lines.isEmpty)
            Text(
              l10n.cartEmpty,
              style: GoogleFonts.montserrat(color: Colors.black54),
            ),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notes,
            decoration: InputDecoration(labelText: l10n.notesOptional),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'اختر ميعاد التوصيل',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.xs),
          if (_slotsLoading)
            const LinearProgressIndicator()
          else if (_slots.isEmpty)
            const Text(
              'لا توجد مواعيد توصيل متاحة حالياً',
              style: TextStyle(color: Colors.red),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedSlotId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _slots
                  .map(
                    (slot) => DropdownMenuItem<String>(
                      value: slot.id,
                      enabled: !slot.isFull,
                      child: Text(
                        slot.isFull
                            ? '${slot.label} (Full Capacity)'
                            : slot.label,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _busy
                  ? null
                  : (value) {
                      final selected = _slots.firstWhere(
                        (s) => s.id == value,
                        orElse: () => _slots.first,
                      );
                      if (selected.isFull) return;
                      setState(() => _selectedSlotId = value);
                    },
            ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Delivery fees: ${_deliveryFee.toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10n.totalAmount(total.toStringAsFixed(2)),
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          if (_error != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _busy ||
                    profile == null ||
                    cart.lines.isEmpty ||
                    _slotsLoading ||
                    !hasAvailableSlots ||
                    _selectedSlotId == null
                ? null
                : _submit,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.confirmOrder),
          ),
        ],
      ),
    );
  }
}

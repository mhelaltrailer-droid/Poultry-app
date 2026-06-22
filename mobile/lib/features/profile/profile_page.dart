import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../auth/auth_controller.dart';
import '../auth/customer_profile.dart';
import '../auth/customer_profile_local_service.dart';
import '../auth/phone_login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = CustomerProfileLocalService();
  CustomerProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await _profileService.load();
    if (!mounted) return;
    final auth = context.read<AuthController>();
    if (profile != null) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
      return;
    }
    if (auth.guestName.trim().isNotEmpty || auth.guestPhone.trim().isNotEmpty) {
      final migrated = CustomerProfile(
        name: auth.guestName.trim(),
        familyName: '',
        mobile: auth.guestPhone.trim(),
        city: 'Obour City',
        district: auth.guestDistrict.trim(),
        addressDetails: auth.guestAddressDetail.trim(),
        deliveryNotes: '',
        phones: auth.guestPhone.trim().isEmpty
            ? []
            : [
                SavedPhone(
                  id: SavedPhone.newId(),
                  label: 'Mobile',
                  number: auth.guestPhone.trim(),
                  isDefault: true,
                ),
              ],
        addresses: auth.guestDistrict.trim().isEmpty &&
                auth.guestAddressDetail.trim().isEmpty
            ? []
            : [
                SavedAddress(
                  id: SavedAddress.newId(),
                  label: 'Home',
                  city: 'Obour City',
                  district: auth.guestDistrict.trim(),
                  addressDetails: auth.guestAddressDetail.trim(),
                  isDefault: true,
                ),
              ],
      );
      await _profileService.save(migrated);
      if (!mounted) return;
      setState(() {
        _profile = migrated;
        _loading = false;
      });
      return;
    }
    setState(() {
      _profile = null;
      _loading = false;
    });
  }

  Future<void> _save(CustomerProfile profile) async {
    await _profileService.save(profile);
    if (!mounted) return;
    await context.read<AuthController>().setGuestContact(
          name: profile.name,
          phone: profile.defaultPhone.number,
          district: profile.defaultAddress.district,
          addressDetail: profile.defaultAddress.addressDetails,
        );
    if (!mounted) return;
    setState(() => _profile = profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.savedSnack)),
    );
  }

  Future<void> _editName() async {
    final profile = _profile;
    if (profile == null) return;
    final ctrl = TextEditingController(text: profile.name);
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labelName),
        content: TextField(
          controller: ctrl,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: l10n.labelName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save)),
        ],
      ),
    );
    if (ok != true) return;
    await _save(profile.copyWith(name: ctrl.text.trim()));
    ctrl.dispose();
  }

  Future<void> _addPhone() async {
    final profile = _profile;
    if (profile == null) return;
    final result = await _phoneDialog();
    if (result == null) return;
    final phones = [
      ...profile.phones.map((p) => p.copyWith(isDefault: false)),
      SavedPhone(
        id: SavedPhone.newId(),
        label: result.label,
        number: result.number,
        isDefault: profile.phones.isEmpty,
      ),
    ];
    await _save(profile.copyWith(phones: phones, mobile: result.number));
  }

  Future<void> _addAddress() async {
    final profile = _profile;
    if (profile == null) return;
    final result = await _addressDialog();
    if (result == null) return;
    final addresses = [
      ...profile.addresses.map((a) => a.copyWith(isDefault: false)),
      SavedAddress(
        id: SavedAddress.newId(),
        label: result.label,
        city: result.city,
        district: result.district,
        addressDetails: result.addressDetails,
        deliveryNotes: result.deliveryNotes,
        isDefault: profile.addresses.isEmpty,
      ),
    ];
    await _save(profile.copyWith(addresses: addresses));
  }

  Future<void> _setDefaultPhone(String id) async {
    final profile = _profile;
    if (profile == null) return;
    final phones = profile.phones
        .map((p) => p.copyWith(isDefault: p.id == id))
        .toList();
    final selected = phones.firstWhere((p) => p.id == id);
    await _save(profile.copyWith(phones: phones, mobile: selected.number));
  }

  Future<void> _setDefaultAddress(String id) async {
    final profile = _profile;
    if (profile == null) return;
    final addresses = profile.addresses
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
    await _save(profile.copyWith(addresses: addresses));
  }

  Future<({String label, String number})?> _phoneDialog() async {
    final l10n = context.l10n;
    final labelCtrl = TextEditingController(text: 'Mobile');
    final numberCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileAddPhone),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: InputDecoration(labelText: l10n.profilePhoneLabel),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(labelText: l10n.phone),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save)),
        ],
      ),
    );
    if (ok != true) return null;
    final number = numberCtrl.text.trim();
    if (!RegExp(r'^01\d{9}$').hasMatch(number)) return null;
    return (label: labelCtrl.text.trim().isEmpty ? 'Mobile' : labelCtrl.text.trim(), number: number);
  }

  Future<({String label, String city, String district, String addressDetails, String deliveryNotes})?> _addressDialog() async {
    final l10n = context.l10n;
    final labelCtrl = TextEditingController(text: l10n.addressLabelHome);
    final districtCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileAddAddress),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: InputDecoration(labelText: l10n.profileAddressLabel),
              ),
              TextField(
                controller: districtCtrl,
                decoration: InputDecoration(labelText: l10n.profileDistrict),
              ),
              TextField(
                controller: detailsCtrl,
                decoration: InputDecoration(labelText: l10n.profileAddressDetails),
              ),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(labelText: l10n.notesOptional),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save)),
        ],
      ),
    );
    if (ok != true) return null;
    if (districtCtrl.text.trim().isEmpty || detailsCtrl.text.trim().isEmpty) return null;
    return (
      label: labelCtrl.text.trim().isEmpty ? l10n.addressLabelHome : labelCtrl.text.trim(),
      city: 'Obour City',
      district: districtCtrl.text.trim(),
      addressDetails: detailsCtrl.text.trim(),
      deliveryNotes: notesCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(l10n.profileTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      l10n.profileEmptyHint,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Colors.black54),
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(
                    AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width),
                  ),
                  children: [
                    Card(
                      child: ListTile(
                        title: Text(l10n.labelName),
                        subtitle: Text(profile.name.isEmpty ? '-' : profile.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: _editName,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(l10n.profilePhonesTitle, style: GoogleFonts.playfairDisplay(fontSize: 20)),
                    SizedBox(height: AppSpacing.xs),
                    Text(l10n.profilePhonesHint, style: GoogleFonts.montserrat(color: Colors.black54)),
                    ...profile.phones.map(
                      (p) => Card(
                        child: RadioListTile<String>(
                          value: p.id,
                          groupValue: profile.phones.firstWhere((x) => x.isDefault, orElse: () => profile.phones.first).id,
                          onChanged: (_) => _setDefaultPhone(p.id),
                          title: Text(p.number),
                          subtitle: Text(p.label),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _addPhone,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.profileAddPhone),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(l10n.profileAddressesTitle, style: GoogleFonts.playfairDisplay(fontSize: 20)),
                    SizedBox(height: AppSpacing.xs),
                    Text(l10n.profileAddressesHint, style: GoogleFonts.montserrat(color: Colors.black54)),
                    ...profile.addresses.map(
                      (a) => Card(
                        child: RadioListTile<String>(
                          value: a.id,
                          groupValue: profile.addresses.firstWhere((x) => x.isDefault, orElse: () => profile.addresses.first).id,
                          onChanged: (_) => _setDefaultAddress(a.id),
                          title: Text('${a.label} — ${a.district}'),
                          subtitle: Text(a.addressDetails),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _addAddress,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(l10n.profileAddAddress),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.logout),
                                content: Text(l10n.backToStartBody),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(l10n.logout),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok && context.mounted) {
                          await auth.logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => const PhoneLoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Text(l10n.logout),
                    ),
                  ],
                ),
    );
  }
}

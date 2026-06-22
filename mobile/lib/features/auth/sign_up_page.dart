import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/app_spacing.dart';
import '../../data/api_client.dart';
import 'auth_controller.dart';
import 'customer_profile.dart';
import 'customer_profile_local_service.dart';
import '../shell/main_shell.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    this.returnToPreviousOnSave = false,
  });

  final bool returnToPreviousOnSave;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const _fixedCity = 'Obour City';
  static const _fallbackDistricts = <String>[
    'Golf City',
    'الحي السابع',
    'الحي السادس',
    'الحي الخامس',
    'الحي الرابع',
    'الحي الثالث',
    'الحي الثامن',
    'اسكان الشباب',
    'الحي الاول',
    'الحي الثاني',
    'الحي التاسع',
    'الحي الترفيهي',
    'دار مصر',
    'حي المجد',
    'حي الكرامة',
    'سكن مصر (العبور الجديدة)',
    'جمعية احمد عرابي',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _familyCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _addressDetailsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _service = CustomerProfileLocalService();

  String? _district;
  bool _saving = false;
  bool _districtsLoading = true;
  List<String> _districts = [];

  bool get _canSave {
    final name = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final addressDetails = _addressDetailsCtrl.text.trim();
    final district = _district?.trim() ?? '';
    return name.isNotEmpty &&
        mobile.isNotEmpty &&
        password.isNotEmpty &&
        addressDetails.isNotEmpty &&
        district.isNotEmpty &&
        !_saving;
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_refresh);
    _mobileCtrl.addListener(_refresh);
    _passwordCtrl.addListener(_refresh);
    _addressDetailsCtrl.addListener(_refresh);
    _loadExisting();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final data = await context.read<ApiClient>().get('/api/districts') as List<dynamic>;
      final districts = data
          .map((e) => (e as Map)['name']?.toString().trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _districts = districts.isEmpty ? List<String>.from(_fallbackDistricts) : districts;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _districts = List<String>.from(_fallbackDistricts);
      });
    } finally {
      if (mounted) setState(() => _districtsLoading = false);
    }
  }

  Future<void> _loadExisting() async {
    final existing = await _service.load();
    if (!mounted || existing == null) return;
    setState(() {
      _nameCtrl.text = existing.name;
      _familyCtrl.text = existing.familyName;
      _mobileCtrl.text = existing.mobile;
      _addressDetailsCtrl.text = existing.addressDetails;
      _notesCtrl.text = existing.deliveryNotes;
      _district = existing.district.isEmpty ? null : existing.district;
    });
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_refresh);
    _mobileCtrl.removeListener(_refresh);
    _passwordCtrl.removeListener(_refresh);
    _addressDetailsCtrl.removeListener(_refresh);
    _nameCtrl.dispose();
    _familyCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    _addressDetailsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String? _required(String? v, String label) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return '$label is required';
    return null;
  }

  String? _mobileValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Mobile is required';
    if (!RegExp(r'^[0-9]+$').hasMatch(t)) return 'Mobile must be numbers only';
    if (!RegExp(r'^01\d{9}$').hasMatch(t)) {
      return 'Mobile must start with 01 and be exactly 11 digits';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Password is required';
    if (t.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(t)) {
      return 'Password must contain letters and/or numbers only';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final district = _district;
    if (district == null || district.trim().isEmpty) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    final profile = CustomerProfile(
      name: _nameCtrl.text.trim(),
      familyName: _familyCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      city: _fixedCity,
      district: district,
      addressDetails: _addressDetailsCtrl.text.trim(),
      deliveryNotes: _notesCtrl.text.trim(),
      phones: [
        SavedPhone(
          id: SavedPhone.newId(),
          label: 'Mobile',
          number: _mobileCtrl.text.trim(),
          isDefault: true,
        ),
      ],
      addresses: [
        SavedAddress(
          id: SavedAddress.newId(),
          label: 'Home',
          city: _fixedCity,
          district: district,
          addressDetails: _addressDetailsCtrl.text.trim(),
          deliveryNotes: _notesCtrl.text.trim(),
          isDefault: true,
        ),
      ],
    );
    try {
      await context.read<AuthController>().registerCustomer(
            name: profile.name,
            familyName: profile.familyName,
            phone: profile.mobile,
            password: _passwordCtrl.text.trim(),
            city: profile.city,
            district: profile.district,
            addressDetail: profile.addressDetails,
            deliveryNotes: profile.deliveryNotes,
          );
      await _service.save(profile);
      _nameCtrl.clear();
      _familyCtrl.clear();
      _mobileCtrl.clear();
      _passwordCtrl.clear();
      _addressDetailsCtrl.clear();
      _notesCtrl.clear();
      _district = null;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ البيانات بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (widget.returnToPreviousOnSave) {
      Navigator.of(context).pop(true);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (route) => false,
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => _required(v, 'Name'),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _familyCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Family Name'),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _mobileCtrl,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Mobile',
                          hintText: '01*********',
                        ),
                        validator: _mobileValidator,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _passwordCtrl,
                        textInputAction: TextInputAction.next,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: _passwordValidator,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        initialValue: _fixedCity,
                        readOnly: true,
                        enabled: false,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        initialValue: _district,
                        decoration: const InputDecoration(labelText: 'District'),
                        isExpanded: true,
                        hint: _districtsLoading ? const Text('Loading...') : null,
                        items: _districts
                            .map(
                              (d) => DropdownMenuItem<String>(
                                value: d,
                                child: Text(
                                  d,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _districtsLoading ? null : (v) => setState(() => _district = v),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return 'District is required';
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _addressDetailsCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Address Details',
                        ),
                        validator: (v) => _required(v, 'Address Details'),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Notes',
                          hintText: 'اكتب أي ملاحظات للتوصيل (اختياري)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canSave ? _save : null,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حفظ'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

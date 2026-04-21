import 'package:flutter/material.dart';
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
  CustomerProfile? _savedProfile;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final profile = await _profileService.load();
    if (!mounted) return;
    setState(() => _savedProfile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();
    final name = _savedProfile?.name.trim().isNotEmpty == true
        ? _savedProfile!.name
        : (auth.guestName.trim().isNotEmpty ? auth.guestName.trim() : '-');
    final mobile = _savedProfile?.mobile.trim().isNotEmpty == true
        ? _savedProfile!.mobile
        : (auth.guestPhone.trim().isNotEmpty ? auth.guestPhone.trim() : '-');
    final address = _savedProfile?.addressDetails.trim().isNotEmpty == true
        ? _savedProfile!.addressDetails
        : (auth.guestAddressDetail.trim().isNotEmpty ? auth.guestAddressDetail.trim() : '-');

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
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width)),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: $name'),
                  SizedBox(height: AppSpacing.xs),
                  Text('Mobile: $mobile'),
                  SizedBox(height: AppSpacing.xs),
                  Text('Address Details: $address'),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          OutlinedButton(
            onPressed: () async {
              if (!context.mounted) return;
              final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      final loc = ctx.l10n;
                      return AlertDialog(
                        title: Text(loc.logout),
                        content: Text(loc.backToStartBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(loc.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(loc.logout),
                          ),
                        ],
                      );
                    },
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

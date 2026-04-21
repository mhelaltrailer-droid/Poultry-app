import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../auth/auth_controller.dart';

/// صلاحية «مسؤول إدارة» لا تتضمن لوحة التحكم في التطبيق.
class StaffNoDashboardPage extends StatelessWidget {
  const StaffNoDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(l10n.staffNoDashboardTitle),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.staffNoDashboardMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(fontSize: 16, height: 1.4),
              ),
              SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.read<AuthController>().logout(),
                child: Text(l10n.staffLogout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

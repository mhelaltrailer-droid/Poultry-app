import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_constants.dart';
import '../../core/responsive/app_spacing.dart';
import 'auth_controller.dart';
import 'sign_up_page.dart';
import '../splash/welcome_hero.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({
    super.key,
    this.playEntranceAnimation = false,
    this.afterCinematicSplash = false,
  });

  /// Staggered reveal of action buttons after cinematic splash.
  final bool playEntranceAnimation;

  /// Hero (welcome + logo) already visible — keep layout, animate buttons only.
  final bool afterCinematicSplash;

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage>
    with SingleTickerProviderStateMixin {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  AnimationController? _entranceCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.playEntranceAnimation) {
      _entranceCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..forward();
    }
  }

  @override
  void dispose() {
    _entranceCtrl?.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Animation<double> _entranceInterval(double start, double end) {
    final ctrl = _entranceCtrl;
    if (ctrl == null) return const AlwaysStoppedAnimation(1);
    return CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, end, curve: Curves.easeInOutCubicEmphasized),
    );
  }

  Widget _entrance({
    required double start,
    required double end,
    required Widget child,
    Offset slide = Offset.zero,
  }) {
    if (!widget.playEntranceAnimation) return child;
    final anim = _entranceInterval(start, end);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(slide.dx * (1 - anim.value), slide.dy * (1 - anim.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  bool _isValidPhone(String value) {
    final p = value.replaceAll(RegExp(r'\s'), '').trim();
    return RegExp(r'^01\d{9}$').hasMatch(p);
  }

  Future<void> _submit() async {
    final phone = _phone.text.trim();
    final password = _password.text;
    if (!_isValidPhone(phone)) {
      setState(() => _error = 'رقم الهاتف يجب أن يبدأ بـ 01 ويتكون من 11 رقم');
      return;
    }
    Navigator.of(context).pop();
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await context.read<AuthController>().signInWithPassword(phone, password);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      _showLoginSheet();
      return;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _showLoginSheet() async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.92,
            builder: (ctx, scrollCtrl) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF9EF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB89B5E).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.loginSheetTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D1D1B),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.phone,
                        hintText: l10n.phoneHint,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1D1B),
                        foregroundColor: const Color(0xFFF3E2BE),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.login,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showSignUpDialog() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(0.9, 1.15);
    final logoWidth = (size.width * 0.58).clamp(200.0, 260.0).toDouble();
    final titleSize = ((size.width * 0.085).clamp(28.0, 36.0) / textScale).toDouble();
    final actionTextSize = (17 / textScale).toDouble();
    final padX = AppSpacing.pagePaddingX(size.width);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/chicken_bg.png',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: const Color(0xFFF7F4EE).withValues(alpha: 0.82)),
          ),
          SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: padX,
                      vertical: AppSpacing.md,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - AppSpacing.md * 2,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _heroSection(
                                l10n: l10n,
                                titleSize: titleSize,
                                logoWidth: logoWidth,
                                textScale: textScale,
                              ),
                              SizedBox(height: AppSpacing.md),
                              _entrance(
                                start: 0.0,
                                end: 0.38,
                                slide: const Offset(0, 22),
                                child: FilledButton(
                                  onPressed: () async {
                                    await context.read<AuthController>().startShopping();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF171717),
                                    foregroundColor: const Color(0xFFF2DEAF),
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    shape: const StadiumBorder(),
                                    elevation: 1.5,
                                  ),
                                  child: Text(
                                    l10n.startShopping,
                                    textScaler: TextScaler.linear(textScale),
                                    style: GoogleFonts.montserrat(
                                      fontSize: actionTextSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm),
                              _entrance(
                                start: 0.18,
                                end: 0.48,
                                slide: const Offset(0, 18),
                                child: OutlinedButton(
                                  onPressed: _showLoginSheet,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF171717),
                                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                                    side: const BorderSide(
                                      color: Color(0xFF171717),
                                      width: 1.2,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm + 2,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(
                                    l10n.login,
                                    textScaler: TextScaler.linear(textScale),
                                    style: GoogleFonts.montserrat(
                                      fontSize: actionTextSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              if (AppConstants.demoMode) ...[
                                SizedBox(height: AppSpacing.sm),
                                FilledButton(
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          await context.read<AuthController>().signInDemoAdmin();
                                        },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFC5A059),
                                    foregroundColor: const Color(0xFF1D1D1B),
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm + 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Demo Login (Admin)',
                                    textScaler: TextScaler.linear(textScale),
                                    style: GoogleFonts.montserrat(
                                      fontSize: actionTextSize - 1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                OutlinedButton(
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          await context.read<AuthController>().signInDemoCustomer();
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF171717),
                                    side: const BorderSide(
                                      color: Color(0xFFC5A059),
                                      width: 1.2,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm + 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Demo Login (Customer)',
                                    textScaler: TextScaler.linear(textScale),
                                    style: GoogleFonts.montserrat(
                                      fontSize: actionTextSize - 1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: AppSpacing.md),
                              _entrance(
                                start: 0.34,
                                end: 0.58,
                                child: Text(
                                  l10n.orDivider,
                                  textAlign: TextAlign.center,
                                  textScaler: TextScaler.linear(textScale),
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFF8B754A),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              _entrance(
                                start: 0.46,
                                end: 0.78,
                                child: TextButton(
                                  onPressed: _showSignUpDialog,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF181818),
                                  ),
                                  child: Text(
                                    l10n.signUp,
                                    textScaler: TextScaler.linear(textScale),
                                    style: GoogleFonts.playfairDisplay(
                                      color: const Color(0xFF181818),
                                      fontSize: actionTextSize,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: const Color(0xFF181818),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm),
                              _entrance(
                                start: 0.58,
                                end: 0.92,
                                child: Text(
                                  l10n.staffWelcomeHint,
                                  textAlign: TextAlign.center,
                                  textScaler: TextScaler.linear(textScale),
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFF8B754A).withValues(alpha: 0.75),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _heroSection({
    required AppLocalizations l10n,
    required double titleSize,
    required double logoWidth,
    required double textScale,
  }) {
    final hero = WelcomeHero(
      welcomeText: l10n.welcome,
      titleSize: titleSize,
      logoWidth: logoWidth,
      textScale: textScale,
    );
    if (widget.afterCinematicSplash) return hero;
    return _entrance(
      start: 0.0,
      end: 0.42,
      slide: const Offset(0, 16),
      child: hero,
    );
  }
}

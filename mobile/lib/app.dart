import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/responsive/app_spacing.dart';
import 'core/locale_controller.dart';
import 'data/api_client.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/phone_login_page.dart';
import 'features/cart/cart_controller.dart';
import 'features/shop/shop_repository.dart';
import 'features/admin/admin_shell.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/cinematic_splash_screen.dart';
import 'features/splash/welcome_animation_gate.dart';
import 'l10n/app_localizations.dart';

class DayTodayApp extends StatelessWidget {
  const DayTodayApp({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleController(initial: initialLocale),
        ),
        ChangeNotifierProvider(create: (_) => WelcomeAnimationGate()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        Provider(
          create: (ctx) {
            final auth = ctx.read<AuthController>();
            return ApiClient(getToken: auth.getToken);
          },
        ),
        Provider(
          create: (ctx) => ShopRepository(ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: const _SessionGate(),
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  bool _sessionReady = false;
  bool _splashComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthController>().loadSession();
      if (!mounted) return;
      await context.read<CartController>().restore();
      if (!mounted) return;
      setState(() => _sessionReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final locale = context.watch<LocaleController>().locale;
    final showSplash = !_splashComplete || !_sessionReady;

    final Widget currentScreen = showSplash
        ? CinematicSplashScreen(
            key: const ValueKey('cinematic-splash'),
            onComplete: () {
              context.read<WelcomeAnimationGate>().markSplashComplete();
              if (mounted) setState(() => _splashComplete = true);
            },
          )
        : !auth.isAuthenticated
            ? PhoneLoginPage(
                key: const ValueKey('phone-login'),
                playEntranceAnimation: true,
                afterCinematicSplash: true,
              )
            : auth.isStaff && auth.canUseInAppDashboard
                ? const AdminShell(key: ValueKey('admin-shell'))
                : const MainShell(key: ValueKey('main-shell'));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DAY TO DAY',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: child ?? const SizedBox.shrink()),
            const _LanguageToggleOverlay(),
          ],
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: Curves.easeInOutCubicEmphasized,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubicEmphasized,
          );
          return FadeTransition(opacity: curved, child: child);
        },
        child: currentScreen,
      ),
    );
  }
}

class _LanguageToggleOverlay extends StatefulWidget {
  const _LanguageToggleOverlay();

  @override
  State<_LanguageToggleOverlay> createState() => _LanguageToggleOverlayState();
}

class _LanguageToggleOverlayState extends State<_LanguageToggleOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gate = context.watch<WelcomeAnimationGate>();
    if (gate.splashComplete && _ctrl?.status != AnimationStatus.completed) {
      _ctrl?.forward();
    }
    return Builder(
      builder: (ctx) {
        final padding = MediaQuery.paddingOf(ctx);
        final rtl = Directionality.of(ctx) == TextDirection.rtl;
        final l10n = AppLocalizations.of(ctx);
        final auth = ctx.watch<AuthController>();
        if (!gate.splashComplete && !auth.isStaff) {
          return const SizedBox.shrink();
        }
        if (!gate.splashComplete && auth.isStaff) {
          return const SizedBox.shrink();
        }
        final anim = _ctrl ?? const AlwaysStoppedAnimation(1.0);
        final topOffset = auth.isStaff
            ? padding.top + kToolbarHeight + AppSpacing.xs
            : padding.top + AppSpacing.xxs;
        return Positioned(
          top: topOffset,
          right: rtl ? null : AppSpacing.xs,
          left: rtl ? AppSpacing.xs : null,
          child: FadeTransition(
            opacity: auth.isStaff
                ? const AlwaysStoppedAnimation(1)
                : CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: auth.isStaff
                  ? const AlwaysStoppedAnimation(1)
                  : Tween<double>(begin: 0.85, end: 1).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                    ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!auth.isStaff) ...[
                    _OverlayCircleButton(
                      semanticLabel: l10n?.appTitle ?? 'Home',
                      icon: Icons.home_outlined,
                      onTap: () async {
                        await context.read<AuthController>().logout();
                      },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  _OverlayCircleButton(
                    semanticLabel: l10n?.changeLanguage ?? 'Language',
                    icon: Icons.language,
                    onTap: () => context.read<LocaleController>().toggleEnAr(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverlayCircleButton extends StatelessWidget {
  const _OverlayCircleButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}

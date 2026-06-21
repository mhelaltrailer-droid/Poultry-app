import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/responsive/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'splash_palette.dart';
import 'splash_particle_field.dart';
import 'welcome_hero.dart';

/// Premium cinematic splash — ends on the same hero layout as [PhoneLoginPage].
class CinematicSplashScreen extends StatefulWidget {
  const CinematicSplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<CinematicSplashScreen> createState() => _CinematicSplashScreenState();
}

class _CinematicSplashScreenState extends State<CinematicSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<SplashParticle> _particles;
  final _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SplashPalette.total)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      })
      ..forward();
    _particles = generateParticles(const Size(400, 800), _random);
  }

  double _interval(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return Curves.easeInOutCubicEmphasized.transform((t - start) / (end - start));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.value;
    final size = MediaQuery.sizeOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(0.9, 1.15);
    final logoWidth = (size.width * 0.58).clamp(200.0, 260.0).toDouble();
    final titleSize = ((size.width * 0.085).clamp(28.0, 36.0) / textScale).toDouble();
    final l10n = AppLocalizations.of(context);

    final particleFloat = _interval(t, 0, SplashPalette.particlesEnd);
    final particleFade = _interval(t, SplashPalette.logoEnd * 0.65, SplashPalette.welcomeEnd);
    final gather = _interval(t, SplashPalette.particlesEnd * 0.45, SplashPalette.logoEnd);
    final logoReveal = _interval(t, SplashPalette.particlesEnd, SplashPalette.logoEnd);
    final welcomeReveal = _interval(t, SplashPalette.logoEnd * 0.78, SplashPalette.welcomeEnd);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/chicken_bg.png',
            fit: BoxFit.cover,
          ),
          Container(color: const Color(0xFFF7F4EE).withValues(alpha: 0.82)),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.5 + particleFloat * 1.5,
              sigmaY: 1.5 + particleFloat * 1.5,
            ),
            child: const SizedBox.expand(),
          ),
          Opacity(
            opacity: (1 - particleFade).clamp(0.0, 1.0),
            child: CustomPaint(
              painter: SplashParticlePainter(
                particles: _particles,
                time: _controller.value * 5,
                gather: gather,
              ),
              size: size,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingX(size.width)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Transform.translate(
                    offset: Offset(0, (1 - welcomeReveal) * 10),
                    child: WelcomeHero(
                      welcomeText: l10n?.welcome ?? 'Welcome',
                      titleSize: titleSize,
                      logoWidth: logoWidth,
                      textScale: textScale,
                      titleOpacity: welcomeReveal,
                      logoReveal: logoReveal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

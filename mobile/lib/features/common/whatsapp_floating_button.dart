import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_constants.dart';

/// WhatsApp shortcut: gold/cream brand + subtle WhatsApp green, soft pulse.
class WhatsAppFloatingButton extends StatefulWidget {
  const WhatsAppFloatingButton({super.key});

  @override
  State<WhatsAppFloatingButton> createState() => _WhatsAppFloatingButtonState();
}

class _WhatsAppFloatingButtonState extends State<WhatsAppFloatingButton>
    with SingleTickerProviderStateMixin {
  static const _waGreen = Color(0xFF128C7E);
  static const _waGlow = Color(0xFF25D366);

  late final AnimationController _pulse;
  late final Animation<double> _breathe;
  bool _hover = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _breathe = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(AppConstants.whatsappUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final enterScale = _visible ? 1.0 : 0.82;

    return SafeArea(
      minimum: const EdgeInsets.only(right: 14, bottom: 14),
      child: Align(
        alignment: Alignment.bottomRight,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.82, end: enterScale),
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: AnimatedBuilder(
              animation: _breathe,
              builder: (context, child) {
                final t = _breathe.value;
                final ringScale = 1.0 + 0.07 * t + (_hover ? 0.04 : 0);
                final glow = 10 + 14 * t + (_hover ? 8.0 : 0);

                return SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.scale(
                        scale: ringScale,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _waGlow.withValues(alpha: 0.35 + 0.2 * t),
                                blurRadius: glow,
                                spreadRadius: 1.5,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: const Color(0xFF2A2A2A).withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openWhatsApp,
                          customBorder: const CircleBorder(),
                          child: Ink(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFF6ECD4),
                                    const Color(0xFFE8DCC4),
                                    Color.lerp(
                                          const Color(0xFFD8EBE0),
                                          _waGlow,
                                          0.12 + 0.08 * t,
                                        ) ??
                                        const Color(0xFFD8EBE0),
                                  ],
                                ),
                                border: Border.all(
                                  color: Color.lerp(
                                        const Color(0xFFC5A059),
                                        _waGreen,
                                        0.25 + 0.15 * t,
                                      ) ??
                                      const Color(0xFFC5A059),
                                  width: 1.35,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 24,
                                    color: Color.lerp(_waGreen, _waGlow, t * 0.5),
                                  ),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _waGlow,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

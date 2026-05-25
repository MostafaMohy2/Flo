import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF8),
      body: Stack(
        children: [
          // ── Gradient blobs ────────────────────────────────────
          const Positioned(
            top: -80,
            right: -60,
            child: _Blob(color:  Color(0xFF8B80D0), size: 280),
          ),
          const Positioned(
            top: 100,
            left: -80,
            child: _Blob(color:  Color(0xFF7B74C8), size: 220),
          ),
          const   Positioned(
            bottom: 80,
            right: -40,
            child: _Blob(color:  Color(0xFF4CAF70), size: 200),
          ),
          const Positioned(
            bottom: -40,
            left: 20,
            child: _Blob(color:  Color(0xFF5BBF7A), size: 180),
          ),

          // ── Frosted glass overlay ─────────────────────────────
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),

          // ── Content ───────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // App icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App name
                  Text(
                    'Flo',
                    style: AppTextStyles.heading1(palette.textPrimary).copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tagline with checkmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF70),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'onboarding.tagline'.tr(),
                        style: AppTextStyles.bodyMedium(
                          const Color(0xFF3D9A58),
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Hero image card
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Main card with image
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/icon/Flo Financial Clarity.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Floating analytics badge (left side)
                        const Positioned(
                          left: -16,
                          bottom: 80,
                          child: _FloatingBadge(
                            icon: Icons.show_chart_rounded,
                            color:  Color(0xFF6C63C0),
                          ),
                        ),

                        // Green check badge (top right)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF70),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRouter.signIn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: AppTextStyles.bodyLarge(Colors.white)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('onboarding.get_started'.tr()),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Fine print
                  Text(
                    'By continuing, you agree to our terms of mindful spending and financial tranquility.',
                    style: AppTextStyles.bodySmall(palette.textSecondary)
                        .copyWith(
                      fontSize: 11,
                      color: palette.textSecondary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.55),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _FloatingBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

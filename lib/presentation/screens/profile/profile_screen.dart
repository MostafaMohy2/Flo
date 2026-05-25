import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/transactions/transactions_bloc.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _aiAlerts       = true;
  bool _weeklySummary  = true;
  bool _budgetWarnings = true;
  String _currency     = 'USD';
  double _monthlyBudget = 3000;
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final path = await sl<SettingsRepository>().get('avatar_path');
    if (!mounted) return;
    setState(() => _avatarPath = (path?.isNotEmpty ?? false) ? path : null);
  }

  Future<void> _setAvatarPath(String? path) async {
    await sl<SettingsRepository>().set('avatar_path', path ?? '');
    if (!mounted) return;
    setState(() => _avatarPath = (path?.isNotEmpty ?? false) ? path : null);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;
    await _setAvatarPath(image.path);
  }

  void _showAvatarSheet() {
    final palette = context.palette;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.cardBorder,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: palette.primary),
              title: Text('profile.take_photo'.tr(),
                  style: AppTextStyles.bodyMedium(palette.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: palette.primary),
              title: Text('profile.pick_gallery'.tr(),
                  style: AppTextStyles.bodyMedium(palette.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: palette.expense),
                title: Text('profile.remove_photo'.tr(),
                    style: AppTextStyles.bodyMedium(palette.expense)),
                onTap: () {
                  Navigator.pop(context);
                  _setAvatarPath(null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar row
            Center(
              child: Column(children: [
                GestureDetector(
                  onTap: _showAvatarSheet,
                  child: Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.primaryLight,
                        ),
                        child: _avatarPath == null
                            ? Icon(Icons.person_outline, size: 40, color: palette.primary)
                            : ClipOval(
                                child: Image.file(
                                  File(_avatarPath!),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person_outline,
                                    size: 40,
                                    color: palette.primary,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: palette.surface, width: 2),
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final name  = state is AuthAuthenticated
                        ? state.user.name
                        : 'profile.account_fallback'.tr();
                    final email = state is AuthAuthenticated ? state.user.email : '';
                    return Column(children: [
                      Text(name, style: AppTextStyles.heading2(palette.textPrimary)),
                      if (email.isNotEmpty)
                        Text(email, style: AppTextStyles.bodySmall(palette.textSecondary)),
                    ]);
                  },
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Budget setting
            const _SectionTitle('profile.budget_section'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('profile.monthly_budget'.tr(),
                      style: AppTextStyles.bodyMedium(palette.textPrimary)),
                  Text('\$${_monthlyBudget.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium(palette.textPrimary).copyWith(
                          fontWeight: FontWeight.w600, color: palette.primary)),
                ]),
                const SizedBox(height: 8),
                Slider(
                  value: _monthlyBudget,
                  min: 500,
                  max: 10000,
                  divisions: 19,
                  activeColor: palette.primary,
                  inactiveColor: palette.primaryLight,
                  onChanged: (v) => setState(() => _monthlyBudget = v),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$500', style: AppTextStyles.bodySmall(palette.textSecondary)),
                  Text('\$10,000', style: AppTextStyles.bodySmall(palette.textSecondary)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // Currency
            const _SectionTitle('profile.currency_section'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _currency,
                  items: ['USD', 'EUR', 'GBP', 'EGP', 'SAR', 'AED'].map((c) =>
                    DropdownMenuItem(
                      value: c,
                      child: Text(c, style: AppTextStyles.bodyMedium(palette.textPrimary)),
                    ),
                  ).toList(),
                  onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Preferences
            const _SectionTitle('profile.preferences_section'),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.tune,
              label: 'profile.settings_tile'.tr(),
              iconColor: palette.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TransactionsBloc>(),
                    child: const SettingsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notifications
            const _SectionTitle('profile.notifications_section'),
            const SizedBox(height: 12),
            _ToggleTile(
              label: 'profile.ai_alerts_title'.tr(),
              subtitle: 'profile.ai_alerts_subtitle'.tr(),
              value: _aiAlerts,
              onChanged: (v) => setState(() => _aiAlerts = v),
            ),
            _ToggleTile(
              label: 'profile.weekly_summary_title'.tr(),
              subtitle: 'profile.weekly_summary_subtitle'.tr(),
              value: _weeklySummary,
              onChanged: (v) => setState(() => _weeklySummary = v),
            ),
            _ToggleTile(
              label: 'profile.budget_warnings_title'.tr(),
              subtitle: 'profile.budget_warnings_subtitle'.tr(),
              value: _budgetWarnings,
              onChanged: (v) => setState(() => _budgetWarnings = v),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('profile.settings_saved'.tr())),
                  );
                },
                child: Text('profile.save_settings'.tr()),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
                child: Text('profile.logout'.tr(),
                    style: AppTextStyles.bodyMedium(palette.textPrimary)
                        .copyWith(color: palette.expense)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Clear transactions moved to Settings with extra safeguards.
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(text.tr(),
        style: AppTextStyles.bodySmall(palette.textSecondary)
            .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8));
  }
}

class _ToggleTile extends StatelessWidget {
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.bodyMedium(palette.textPrimary)
              .copyWith(fontWeight: FontWeight.w500)),
          Text(subtitle, style: AppTextStyles.bodySmall(palette.textSecondary)),
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: palette.primary,
        ),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;
  const _ActionTile({required this.icon, required this.label, required this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Row(children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium(palette.textPrimary)
                .copyWith(color: iconColor)),
            const Spacer(),
            Icon(Icons.chevron_right, color: palette.textSecondary, size: 18),
          ]),
        ),
      ),
    );
  }
}

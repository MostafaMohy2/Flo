import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/transactions/transactions_bloc.dart';
import '../../blocs/transactions/transactions_event.dart';
import '../../blocs/transactions/transactions_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _isClearing = false;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _setLocale(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    await sl<SettingsRepository>().set('locale_code', locale.languageCode);
  }

  Future<bool> _confirmClearDialog(BuildContext context) async {
    final palette = context.palette;
    _confirmCtrl.clear();
    var invalid = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('settings.clear_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settings.clear_subtitle'.tr(),
                  style: AppTextStyles.bodySmall(palette.textSecondary)),
              const SizedBox(height: 12),
              Text('settings.type_confirm_label'.tr(),
                  style: AppTextStyles.bodySmall(palette.textSecondary)
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmCtrl,
                decoration: InputDecoration(
                  hintText: 'settings.type_confirm_hint'.tr(),
                  errorText:
                      invalid ? 'settings.type_confirm_error'.tr() : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                final text = _confirmCtrl.text.trim().toUpperCase();
                if (text != 'CLEAR') {
                  setState(() => invalid = true);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text('settings.clear_confirm'.tr(),
                  style: TextStyle(color: palette.expense)),
            ),
          ],
        ),
      ),
    );

    return result == true;
  }

  Future<void> _clearTransactions(BuildContext context) async {
    if (_isClearing) return;
    final confirmed = await _confirmClearDialog(context);
    if (!confirmed || !mounted) return;

    final palette = context.palette;
    setState(() => _isClearing = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('settings.clearing'.tr(),
                  style: AppTextStyles.bodyMedium(palette.textPrimary)),
            ),
          ],
        ),
      ),
    );

    final bloc = context.read<TransactionsBloc>();
    bloc.add(const ClearTransactions());
    final result = await bloc.stream.firstWhere(
      (state) => state is TransactionsLoaded || state is TransactionsError,
    );

    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _isClearing = false);

    if (result is TransactionsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('settings.cleared_success'.tr()),
        action: SnackBarAction(
          label: 'settings.undo'.tr(),
          onPressed: () async {
            bloc.add(const UndoClearTransactions());
            final undoResult = await bloc.stream.firstWhere(
              (state) => state is TransactionsLoaded || state is TransactionsError,
            );
            if (!mounted) return;
            if (undoResult is TransactionsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(undoResult.message)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('settings.undo_success'.tr())),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text('settings.title'.tr(),
            style: AppTextStyles.heading2(palette.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(text: 'settings.theme'.tr()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isDark ? 'settings.dark'.tr() : 'settings.light'.tr(),
                      style: AppTextStyles.bodyMedium(palette.textPrimary)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (v) => context
                        .read<ThemeCubit>()
                        .setTheme(v ? ThemeMode.dark : ThemeMode.light),
                    activeThumbColor: palette.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(text: 'settings.language'.tr()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<bool>(
                  isExpanded: true,
                  value: isArabic,
                  items: [
                    DropdownMenuItem(
                      value: false,
                      child: Text('settings.english'.tr(),
                          style: AppTextStyles.bodyMedium(palette.textPrimary)),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('settings.arabic'.tr(),
                          style: AppTextStyles.bodyMedium(palette.textPrimary)),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    _setLocale(context, Locale(v ? 'ar' : 'en'));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(text: 'settings.data_section'.tr()),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.delete_sweep_outlined,
              label: 'settings.clear_transactions'.tr(),
              subtitle: 'settings.clear_tile_subtitle'.tr(),
              iconColor: palette.expense,
              onTap: _isClearing ? null : () => _clearTransactions(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(text,
        style: AppTextStyles.bodySmall(palette.textSecondary)
            .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8));
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.bodyMedium(palette.textPrimary)
                            .copyWith(color: iconColor)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: AppTextStyles.bodySmall(palette.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: palette.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

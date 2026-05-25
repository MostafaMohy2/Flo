import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/anomaly_result.dart';

class AnomalyDetailScreen extends StatelessWidget {
  final AnomalyResult result;
  const AnomalyDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pct = result.percentageIncrease?.toStringAsFixed(0) ?? '—';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text('anomaly.title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.expenseLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.expense.withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: palette.expense.withValues(alpha: 0.15)),
                    child: Icon(Icons.warning_amber_rounded, color: palette.expense, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('anomaly.detected_title'.tr(),
                        style: AppTextStyles.heading3(palette.textPrimary)),
                    if (result.category != null)
                      Text('anomaly.category_prefix'.tr(args: [
                        '${result.category![0].toUpperCase()}${result.category!.substring(1)}'
                      ]),
                          style: AppTextStyles.bodySmall(palette.textSecondary)),
                  ])),
                ]),
                if (result.message != null) ...[
                  const SizedBox(height: 12),
                  Text(result.message!,
                      style: AppTextStyles.bodyMedium(palette.textPrimary)),
                ],
              ]),
            ),
            const SizedBox(height: 24),

            // Comparison card
            Text('anomaly.comparison_title'.tr(),
                style: AppTextStyles.heading3(palette.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Column(children: [
                _CompareRow(
                  label: 'anomaly.this_week'.tr(),
                  amount: result.currentWeekAmount ?? 0,
                  color: palette.expense,
                  isHigher: true,
                ),
                const SizedBox(height: 16),
                _CompareRow(
                  label: 'anomaly.four_week_avg'.tr(),
                  amount: result.averageWeekAmount ?? 0,
                  color: palette.income,
                  isHigher: false,
                ),
                const SizedBox(height: 16),
                Divider(color: palette.cardBorder),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('anomaly.increase'.tr(),
                      style: AppTextStyles.bodyMedium(palette.textSecondary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.expenseLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('+$pct%',
                        style: AppTextStyles.bodyMedium(palette.expenseText)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.savings_outlined),
                label: Text('anomaly.set_budget'.tr()),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: palette.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('anomaly.dismiss'.tr(),
                    style: AppTextStyles.bodyLarge(palette.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isHigher;
  const _CompareRow({required this.label, required this.amount, required this.color, required this.isHigher});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: AppTextStyles.bodyMedium(palette.textPrimary))),
      Text(CurrencyFormatter.format(amount),
          style: AppTextStyles.bodyMedium(palette.textPrimary).copyWith(
            fontWeight: FontWeight.w600,
            color: isHigher ? palette.expenseText : palette.incomeText,
          )),
    ]);
  }
}

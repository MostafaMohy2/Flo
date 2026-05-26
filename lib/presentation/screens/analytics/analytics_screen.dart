import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/analytics/analytics_event.dart';
import '../../blocs/analytics/analytics_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<AnalyticsBloc>().add(LoadAnalytics(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text('analytics.title'.tr())),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading || state is AnalyticsInitial) {
            return Center(child: CircularProgressIndicator(color: palette.primary));
          }
          if (state is AnalyticsLoaded) {
            return _AnalyticsBody(state: state);
          }
          return Center(child: Text('analytics.load_error'.tr()));
        },
      ),
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  final AnalyticsLoaded state;
  const _AnalyticsBody({required this.state});

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final breakdown = widget.state.categoryBreakdown;
    final monthly   = widget.state.monthlyTotals;
    final total     = breakdown.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly bar chart
          Text('analytics.last_6_months'.tr(),
              style: AppTextStyles.heading3(palette.textPrimary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.cardBorder),
            ),
            child: monthly.isEmpty
                ? Center(child: Text('analytics.no_data'.tr()))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final now = DateTime.now();
                              final date = DateTime(now.year, now.month - 5 + value.toInt());
                              final name = DateFormat.MMM(context.locale.toString()).format(date);
                              return Text(
                                name,
                                style: AppTextStyles.bodySmall(palette.textSecondary)
                                    .copyWith(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(monthly.length, (i) => BarChartGroupData(
                        x: i,
                        barRods: [BarChartRodData(
                          toY: monthly[i],
                          color: palette.primary,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: monthly.reduce((a, b) => a > b ? a : b) * 1.2,
                            color: palette.primaryLight,
                          ),
                        )],
                      )),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Donut chart
          if (breakdown.isNotEmpty) ...[
            Text('analytics.spending_by_category'.tr(),
                style: AppTextStyles.heading3(palette.textPrimary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                            });
                          },
                        ),
                        sections: _buildSections(breakdown, total),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: breakdown.entries.map((e) {
                        final meta    = CategoryMeta.of(e.key);
                        final percent = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(
                              color: meta.color, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(meta.label,
                                style: AppTextStyles.bodySmall(palette.textSecondary)
                                    .copyWith(fontSize: 12))),
                            Text('$percent%',
                                style: AppTextStyles.bodySmall(palette.textPrimary)
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                          ]),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top categories ranked
            Text('analytics.top_categories'.tr(),
                style: AppTextStyles.heading3(palette.textPrimary)),
            const SizedBox(height: 12),
            ...(_sortedEntries(breakdown).map((e) {
              final meta    = CategoryMeta.of(e.key);
              final percent = total > 0 ? e.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: meta.lightColor),
                      child: Icon(meta.icon, size: 18, color: meta.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(meta.label,
                          style: AppTextStyles.bodyMedium(palette.textPrimary)
                              .copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: meta.lightColor,
                          valueColor: AlwaysStoppedAnimation<Color>(meta.color),
                          minHeight: 6,
                        ),
                      ),
                    ])),
                    const SizedBox(width: 12),
                    Text(CurrencyFormatter.format(e.value),
                        style: AppTextStyles.bodyMedium(palette.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
              );
            })),

            // AI insight card
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.alertBorder),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.auto_awesome, color: palette.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('analytics.ai_insight'.tr(),
                      style: AppTextStyles.bodySmall(palette.primary)
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    breakdown.isNotEmpty
                        ? 'analytics.ai_insight_message'.tr(args: [
                            CategoryMeta.of(_sortedEntries(breakdown).first.key).label,
                            (((_sortedEntries(breakdown).first.value / total) * 100)
                                    .toStringAsFixed(0))
                          ])
                        : 'analytics.ai_insight_empty'.tr(),
                    style: AppTextStyles.bodySmall(palette.textPrimary),
                  ),
                ])),
              ]),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(Map<TransactionCategory, double> breakdown, double total) {
    final entries = _sortedEntries(breakdown);
    return List.generate(entries.length, (i) {
      final meta    = CategoryMeta.of(entries[i].key);
      final touched = i == _touchedIndex;
      return PieChartSectionData(
        color: meta.color,
        value: entries[i].value,
        radius: touched ? 22 : 18,
        showTitle: false,
      );
    });
  }

  List<MapEntry<TransactionCategory, double>> _sortedEntries(Map<TransactionCategory, double> map) {
    final list = map.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}

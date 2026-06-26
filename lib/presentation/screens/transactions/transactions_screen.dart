import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/services/export_service.dart';
import '../../blocs/transactions/transactions_bloc.dart';
import '../../blocs/transactions/transactions_event.dart';
import '../../blocs/transactions/transactions_state.dart';
import '../add_expense/add_expense_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  TransactionCategory? _filterCategory;

  void _showExportPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(exportService: sl<ExportService>()),
    );
  }

  void _goToAddExpense() {
    final txBloc = context.read<TransactionsBloc>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: txBloc,
        child: const AddExpenseScreen(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'transactions.title'.tr(),
                      style: AppTextStyles.heading1(palette.textPrimary),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Export to Excel',
                    icon: Icon(Icons.file_download_outlined,
                        color: palette.textSecondary),
                    onPressed: _showExportPicker,
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: palette.primary, size: 28),
                    onPressed: _goToAddExpense,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Search bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'transactions.search_hint'.tr(),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: palette.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Category filter chips ────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'transactions.filter_all'.tr(),
                    selected: _filterCategory == null,
                    onTap: () => setState(() => _filterCategory = null),
                    palette: context.palette,
                  ),
                  ...TransactionCategory.values.map((cat) {
                    final meta = CategoryMeta.of(cat);
                    return _FilterChip(
                      label: meta.label,
                      selected: _filterCategory == cat,
                      onTap: () => setState(() => _filterCategory == cat
                          ? _filterCategory = null
                          : _filterCategory = cat),
                      palette: context.palette,
                      color: meta.color,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<TransactionsBloc, TransactionsState>(
                builder: (context, state) {
                  if (state is TransactionsLoading) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: palette.primary));
                  }
                  if (state is TransactionsLoaded) {
                    var list = state.transactions;

                    if (_filterCategory != null) {
                      list = list
                          .where((t) => t.category == _filterCategory)
                          .toList();
                    }
                    if (_searchQuery.isNotEmpty) {
                      list = list
                          .where((t) => t.merchantName
                              .toLowerCase()
                              .contains(_searchQuery))
                          .toList();
                    }

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 56, color: palette.textSecondary),
                            const SizedBox(height: 16),
                            Text('transactions.empty'.tr(),
                                style: AppTextStyles.bodyMedium(
                                    palette.textSecondary)),
                          ],
                        ),
                      );
                    }

                    // Group by date
                    final grouped = <String, List<Transaction>>{};
                    for (final t in list) {
                      grouped
                          .putIfAbsent(
                              DateFormatter.toDisplay(t.date), () => [])
                          .add(t);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: grouped.length,
                      itemBuilder: (context, i) {
                        final key  = grouped.keys.elementAt(i);
                        final txns = grouped[key]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Row(children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: palette.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  key,
                                  style: AppTextStyles.bodySmall(
                                          palette.textSecondary)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                      color: palette.cardBorder, height: 1),
                                ),
                              ]),
                            ),
                            ...txns.map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _TxCard(
                                    transaction: t,
                                    onDelete: () => context
                                        .read<TransactionsBloc>()
                                        .add(DeleteTransaction(t.id)),
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final dynamic palette;
  final Color? color;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.palette,
      this.color});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? palette.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : palette.cardBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Transaction card ──────────────────────────────────────────────────────────

class _TxCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  const _TxCard({required this.transaction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final palette   = context.palette;
    final meta      = CategoryMeta.of(transaction.category);
    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: palette.expenseLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: palette.expense),
            const SizedBox(width: 4),
            Text('Delete',
                style: TextStyle(
                    color: palette.expense, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.cardBorder),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: meta.lightColor,
              ),
              child: Icon(meta.icon, size: 20, color: meta.color),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchantName,
                    style: AppTextStyles.bodyMedium(palette.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: meta.lightColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        meta.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: meta.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.toShort(transaction.date),
                      style:
                          AppTextStyles.bodySmall(palette.textSecondary),
                    ),
                  ]),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isExpense ? palette.expenseText : palette.incomeText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Export bottom sheet ───────────────────────────────────────────────────────

class _ExportSheet extends StatefulWidget {
  final ExportService exportService;
  const _ExportSheet({required this.exportService});

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  int _selectedYear  = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _loading      = false;

  static const _months = [
    'January', 'February', 'March',     'April',   'May',      'June',
    'July',    'August',   'September', 'October', 'November', 'December',
  ];

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      await widget.exportService.exportMonth(_selectedYear, _selectedMonth);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final now     = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: palette.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Export Expenses',
              style: AppTextStyles.heading2(palette.textPrimary)),
          const SizedBox(height: 4),
          Text('Choose the month to export',
              style: AppTextStyles.bodySmall(palette.textSecondary)),
          const SizedBox(height: 20),

          // Year selector
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              onPressed: () => setState(() => _selectedYear--),
              icon: Icon(Icons.chevron_left, color: palette.textPrimary),
            ),
            Text('$_selectedYear',
                style: AppTextStyles.heading3(palette.textPrimary)
                    .copyWith(fontSize: 20)),
            IconButton(
              onPressed: _selectedYear < now.year
                  ? () => setState(() => _selectedYear++)
                  : null,
              icon: Icon(Icons.chevron_right, color: palette.textPrimary),
            ),
          ]),
          const SizedBox(height: 12),

          // Month grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            childAspectRatio: 2.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(12, (i) {
              final month    = i + 1;
              final isFuture = _selectedYear == now.year && month > now.month;
              final isSel    = _selectedMonth == month;
              return GestureDetector(
                onTap: isFuture ? null : () => setState(() => _selectedMonth = month),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: isSel ? palette.primary : palette.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? palette.primary : palette.cardBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _months[i].substring(0, 3),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSel
                          ? Colors.white
                          : isFuture
                              ? palette.cardBorder
                              : palette.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _export,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.download_outlined),
              label: Text(_loading
                  ? 'Generating...'
                  : 'Export ${_months[_selectedMonth - 1]} $_selectedYear'),
            ),
          ),
        ],
      ),
    );
  }
}

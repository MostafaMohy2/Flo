import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
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

  final _categories = [null, ...TransactionCategory.values];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text('transactions.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final txBloc = context.read<TransactionsBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: txBloc,
                    child: const AddExpenseScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'transactions.search_hint'.tr(),
                prefixIcon: Icon(Icons.search, color: palette.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = _filterCategory == cat;
                final label = cat == null ? 'transactions.filter_all'.tr() : CategoryMeta.of(cat).label;
                return GestureDetector(
                  onTap: () => setState(() => _filterCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? palette.primary : palette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected ? palette.primary : palette.cardBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(label,
                        style: AppTextStyles.bodySmall(palette.textSecondary).copyWith(
                          color: isSelected ? Colors.white : palette.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return Center(child: CircularProgressIndicator(color: palette.primary));
                }
                if (state is TransactionsLoaded) {
                  var list = state.transactions;

                  if (_filterCategory != null) {
                    list = list.where((t) => t.category == _filterCategory).toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    list = list.where((t) => t.merchantName.toLowerCase().contains(_searchQuery)).toList();
                  }

                  if (list.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off, size: 48, color: palette.textSecondary),
                        const SizedBox(height: 12),
                        Text('transactions.empty'.tr(),
                            style: AppTextStyles.bodyMedium(palette.textSecondary)),
                      ]),
                    );
                  }

                  // Group by date
                  final grouped = <String, List<Transaction>>{};
                  for (final t in list) {
                    final key = DateFormatter.toDisplay(t.date);
                    grouped.putIfAbsent(key, () => []).add(t);
                  }

                  final keys = grouped.keys.toList();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: keys.length,
                    itemBuilder: (context, i) {
                      final key = keys[i];
                      final txns = grouped[key]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              key,
                              style: AppTextStyles.bodySmall(palette.textSecondary)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ...txns.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TxRow(
                              transaction: t,
                              onDelete: () => context.read<TransactionsBloc>().add(DeleteTransaction(t.id)),
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
    );
  }
}

class _TxRow extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  const _TxRow({required this.transaction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
        child: Icon(Icons.delete_outline, color: palette.expense),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: meta.lightColor),
              child: Icon(meta.icon, size: 20, color: meta.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(transaction.merchantName,
                  style: AppTextStyles.bodyMedium(palette.textPrimary)
                    .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: meta.lightColor, borderRadius: BorderRadius.circular(4)),
                    child: Text(meta.label.toUpperCase(),
                        style: AppTextStyles.labelSmall(meta.color)),
                  ),
                  const SizedBox(width: 6),
                  Text(DateFormatter.toShort(transaction.date),
                      style: AppTextStyles.bodySmall(palette.textSecondary)),
                ]),
              ]),
            ),
            Text(
              '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
              style: isExpense
                  ? AppTextStyles.amountExpense(palette.expenseText)
                  : AppTextStyles.amountIncome(palette.incomeText),
            ),
          ],
        ),
      ),
    );
  }
}

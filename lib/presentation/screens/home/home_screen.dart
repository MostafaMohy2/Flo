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
import '../../blocs/anomaly/anomaly_bloc.dart';
import '../../blocs/anomaly/anomaly_state.dart';
import '../../blocs/anomaly/anomaly_event.dart';
import '../add_expense/add_expense_screen.dart';
import '../analytics/analytics_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../profile/profile_screen.dart';
import '../anomaly_detail/anomaly_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime _selectedMonth = DateTime.now();

  final List<Widget> _screens = const [
    _HomeBody(),
    AnalyticsScreen(),
    SizedBox.shrink(), // placeholder for FAB
    AiAssistantScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<TransactionsBloc>().add(
          LoadTransactionsByMonth(_selectedMonth.year, _selectedMonth.month),
        );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    context.read<TransactionsBloc>().add(
          LoadTransactionsByMonth(_selectedMonth.year, _selectedMonth.month),
        );
  }

  void _nextMonth() {
    if (_selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    context.read<TransactionsBloc>().add(
          LoadTransactionsByMonth(_selectedMonth.year, _selectedMonth.month),
        );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: _currentIndex == 0
          ? _HomeBody(
              selectedMonth: _selectedMonth,
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
            )
          : _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: palette.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) return;
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final DateTime? selectedMonth;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const _HomeBody({this.selectedMonth, this.onPreviousMonth, this.onNextMonth});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: palette.primaryLight,
                        child: Icon(Icons.person_outline, color: palette.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('app.title'.tr(),
                          style: AppTextStyles.heading3(palette.primary)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: palette.textPrimary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('home.greeting'.tr(),
                      style: AppTextStyles.bodyMedium(palette.textSecondary)),
                  Text('home.overview'.tr(),
                      style: AppTextStyles.heading1(palette.textPrimary)),
                  const SizedBox(height: 4),
                  // Month selector
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: onPreviousMonth,
                        child: Icon(Icons.chevron_left, size: 20, color: palette.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.cardBorder),
                        ),
                        child: Text(
                          DateFormatter.toMonthYear(selectedMonth ?? DateTime.now()),
                          style: AppTextStyles.bodySmall(palette.textPrimary)
                              .copyWith(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onNextMonth,
                        child: Icon(Icons.chevron_right, size: 20, color: palette.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Balance card + anomaly banner
                  BlocBuilder<TransactionsBloc, TransactionsState>(
                    builder: (context, state) {
                      if (state is TransactionsLoaded) {
                        return _BalanceCard(
                          balance: state.balance,
                          income: state.totalIncome,
                          expenses: state.totalExpenses,
                        );
                      }
                      return const _BalanceCardSkeleton();
                    },
                  ),
                  const SizedBox(height: 12),
                  // AI anomaly alert banner
                  BlocBuilder<AnomalyBloc, AnomalyState>(
                    builder: (context, state) {
                      if (state is AnomalyDetected) {
                        return _AnomalyBanner(
                          message: state.result.message ?? 'Unusual spending detected.',
                          onDismiss: () => context.read<AnomalyBloc>().add(const DismissAnomaly()),
                          onViewDetails: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AnomalyDetailScreen(result: state.result),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('home.recent_transactions'.tr(),
                          style: AppTextStyles.heading3(palette.textPrimary)),
                      GestureDetector(
                        onTap: () {},
                        child: Text('home.see_all'.tr(),
                            style: AppTextStyles.bodyMedium(palette.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, state) {
              if (state is TransactionsLoading) {
                return SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: palette.primary),
                  )),
                );
              }
              if (state is TransactionsLoaded) {
                final recent = state.transactions.take(5).toList();
                if (recent.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: palette.textSecondary),
                        const SizedBox(height: 12),
                        Text('home.empty_transactions'.tr(),
                            style: AppTextStyles.bodyMedium(palette.textSecondary)),
                      ]),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionCard(transaction: recent[i]),
                      ),
                      childCount: recent.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance, income, expenses;
  const _BalanceCard({required this.balance, required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('home.total_balance'.tr(),
              style: AppTextStyles.bodySmall(palette.textSecondary)),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.format(balance),
              style: AppTextStyles.balanceLarge(palette.textPrimary)),
          const SizedBox(height: 16),
          Divider(color: palette.cardBorder, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _BalanceItem(label: 'home.income'.tr(), amount: income, isIncome: true)),
              Expanded(child: _BalanceItem(label: 'home.expenses'.tr(), amount: expenses, isIncome: false)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;
  const _BalanceItem({required this.label, required this.amount, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isIncome ? palette.incomeLight : palette.expenseLight,
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 16,
            color: isIncome ? palette.income : palette.expense,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall(palette.textSecondary)),
            Text(
              CurrencyFormatter.format(amount),
              style: AppTextStyles.bodyMedium(palette.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                color: isIncome ? palette.incomeText : palette.expenseText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BalanceCardSkeleton extends StatelessWidget {
  const _BalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Center(child: CircularProgressIndicator(color: palette.primary)),
    );
  }
}

class _AnomalyBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;
  const _AnomalyBanner({required this.message, required this.onDismiss, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.alertBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.alertBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: palette.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,
                    style: AppTextStyles.bodySmall(palette.textPrimary)
                        .copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onViewDetails,
                  child: Text('home.view_details'.tr(),
                      style: AppTextStyles.bodySmall(palette.primary)
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 16, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta      = CategoryMeta.of(transaction.category);
    final isExpense = transaction.type == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: meta.lightColor),
            child: Icon(meta.icon, size: 20, color: meta.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.merchantName,
                    style: AppTextStyles.bodyMedium(palette.textPrimary)
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: meta.lightColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(meta.label.toUpperCase(),
                        style: AppTextStyles.labelSmall(meta.color)),
                  ),
                  const SizedBox(width: 6),
                  Text(DateFormatter.toShort(transaction.date),
                      style: AppTextStyles.bodySmall(palette.textSecondary)),
                ]),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
            style: isExpense
                ? AppTextStyles.amountExpense(palette.expenseText)
                : AppTextStyles.amountIncome(palette.incomeText),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BottomAppBar(
      color: palette.navBar,
      elevation: 4,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'home.nav_home'.tr(),         index: 0, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'home.nav_analytics'.tr(),   index: 1, current: currentIndex, onTap: onTap),
            const SizedBox(width: 48),
            _NavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'home.nav_ai'.tr(), index: 3, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'home.nav_profile'.tr(),      index: 4, current: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActive ? activeIcon : icon,
              size: 22, color: isActive ? palette.primary : palette.textSecondary),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSmall(isActive ? palette.primary : palette.textSecondary)),
        ],
      ),
    );
  }
}

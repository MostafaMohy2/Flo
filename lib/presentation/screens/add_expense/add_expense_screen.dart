import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/ocr_service.dart';
import '../../blocs/transactions/transactions_bloc.dart';
import '../../blocs/transactions/transactions_event.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool _isManual = true;
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  final _amountCtrl   = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _noteCtrl     = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isScanning = false;
  final _ocr = OcrService();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _noteCtrl.dispose();
    _ocr.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt() async {
    final picker = ImagePicker();
    final image  = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80, // compress from ~5MB to ~200-400KB
    );
    if (image == null) return;

    setState(() => _isScanning = true);
    try {
      final result = await _ocr.parseReceipt(image);
      if (result != null) {
        if (result['merchantName'] != null) _merchantCtrl.text = result['merchantName'];
        if (result['amount']       != null) _amountCtrl.text   = (result['amount'] as double).toStringAsFixed(2);
        if (result['date']         != null) setState(() => _date = result['date']);
        if (result['category']     != null) {
          try {
            _category = TransactionCategory.values
                .byName(result['category'].toString().toLowerCase());
          } catch (_) {}
        }
        setState(() => _isManual = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not read receipt: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _pickDate() async {
    final palette = context.palette;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: palette.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('add_expense.amount_invalid'.tr())),
      );
      return;
    }
    if (_merchantCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('add_expense.merchant_required'.tr())),
      );
      return;
    }

    final transaction = Transaction(
      id:           const Uuid().v4(),
      merchantName: _merchantCtrl.text.trim(),
      amount:       amount,
      type:         _type,
      category:     _category,
      date:         _date,
      note:         _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    context.read<TransactionsBloc>().add(AddTransaction(transaction));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('add_expense.title'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Manual / Scan toggle
              Container(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(child: _ToggleTab(label: 'add_expense.manual'.tr(), icon: Icons.edit_outlined,    isActive: _isManual,  onTap: () => setState(() => _isManual = true))),
                    Expanded(child: _ToggleTab(label: 'add_expense.scan_receipt'.tr(), icon: Icons.document_scanner_outlined, isActive: !_isManual, onTap: () => setState(() => _isManual = false))),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!_isManual) ...[
                _ScanArea(isScanning: _isScanning, onScan: _scanReceipt),
                const SizedBox(height: 24),
              ],

              // Income / Expense toggle
              Row(
                children: [
                  Expanded(child: _TypeChip(
                    label: 'add_expense.expense'.tr(),
                    isActive: _type == TransactionType.expense,
                    activeColor: palette.expense,
                    activeLightColor: palette.expenseLight,
                    onTap: () => setState(() => _type = TransactionType.expense),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _TypeChip(
                    label: 'add_expense.income'.tr(),
                    isActive: _type == TransactionType.income,
                    activeColor: palette.income,
                    activeLightColor: palette.incomeLight,
                    onTap: () => setState(() => _type = TransactionType.income),
                  )),
                ],
              ),
              const SizedBox(height: 24),

              // Amount
              Center(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.balanceLarge(palette.textPrimary),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Merchant name
              TextField(
                controller: _merchantCtrl,
                decoration: InputDecoration(
                  labelText: 'add_expense.merchant_label'.tr(),
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Category picker
              Text('add_expense.category'.tr(),
                  style: AppTextStyles.bodySmall(palette.textSecondary)
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TransactionCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  final label = cat.name[0].toUpperCase() + cat.name.substring(1);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? palette.primary : palette.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? palette.primary : palette.cardBorder),
                      ),
                      child: Text(label, style: AppTextStyles.bodySmall(palette.textSecondary).copyWith(
                        color: isSelected ? Colors.white : palette.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: palette.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: AppTextStyles.bodyMedium(palette.textPrimary),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: palette.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note (optional)
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: 'add_expense.note_label'.tr(),
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text('add_expense.save'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleTab({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? palette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: isActive ? Colors.white : palette.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall(palette.textSecondary).copyWith(
            color: isActive ? Colors.white : palette.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          )),
        ]),
      ),
    );
  }
}

class _ScanArea extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onScan;
  const _ScanArea({required this.isScanning, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onScan,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: palette.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.alertBorder, width: 2),
        ),
        child: Center(
          child: isScanning
              ? CircularProgressIndicator(color: palette.primary)
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.document_scanner_outlined, size: 40, color: palette.primary),
                  const SizedBox(height: 10),
                  Text('add_expense.scan_hint'.tr(),
                      style: AppTextStyles.bodyMedium(palette.primary)),
                  Text('add_expense.scan_subtitle'.tr(),
                      style: AppTextStyles.bodySmall(palette.primaryText)),
                ]),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor, activeLightColor;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.isActive, required this.activeColor, required this.activeLightColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeLightColor : palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? activeColor : palette.cardBorder),
        ),
        child: Center(
          child: Text(label, style: AppTextStyles.bodyMedium(palette.textSecondary).copyWith(
            color: isActive ? activeColor : palette.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          )),
        ),
      ),
    );
  }
}

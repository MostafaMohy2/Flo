import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../repositories/transaction_repository.dart';
import 'download_helper.dart';

class ExportService {
  final TransactionRepository _repo;
  ExportService(this._repo);

  Future<void> exportMonth(int year, int month) async {
    final transactions = await _repo.getByMonth(year, month);
    final bytes        = _buildExcel(transactions, year, month);
    final monthName    = DateFormat('MMMM_yyyy').format(DateTime(year, month));
    await downloadExcel(bytes, 'Flo_Expenses_$monthName.xlsx');
  }

  Uint8List _buildExcel(
      List<Transaction> transactions, int year, int month) {
    final workbook = Workbook();
    final sheet    = workbook.worksheets[0];
    sheet.name     = 'Expenses';

    // ── Column widths ─────────────────────────────────────────
    sheet.setColumnWidthInPixels(1, 100); // Date
    sheet.setColumnWidthInPixels(2, 200); // Merchant
    sheet.setColumnWidthInPixels(3, 120); // Category
    sheet.setColumnWidthInPixels(4, 90);  // Type
    sheet.setColumnWidthInPixels(5, 110); // Amount

    final monthLabel = DateFormat('MMMM yyyy').format(DateTime(year, month));

    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double totalIncome   = 0;
    double totalExpenses = 0;
    for (final t in sorted) {
      if (t.type == TransactionType.expense &&
          t.category != TransactionCategory.income) {
        totalExpenses += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }
    final net      = totalIncome - totalExpenses;
    final pctSpent = totalIncome > 0
        ? '${(totalExpenses / totalIncome * 100).toStringAsFixed(1)}%'
        : '0%';

    // ── Row 1: Title ──────────────────────────────────────────
    sheet.setRowHeightInPixels(1, 40);
    final title = sheet.getRangeByName('A1');
    title.setText('Flo — Expense Tracking');
    title.cellStyle.bold      = true;
    title.cellStyle.fontSize  = 18;
    title.cellStyle.fontColor = '#1B3A6B';

    // ── Row 2: Month subtitle ─────────────────────────────────
    sheet.setRowHeightInPixels(2, 22);
    final subtitle = sheet.getRangeByName('A2');
    subtitle.setText(monthLabel);
    subtitle.cellStyle.fontSize  = 10;
    subtitle.cellStyle.fontColor = '#5C5C72';

    // ── Row 3: Spacer ─────────────────────────────────────────
    sheet.setRowHeightInPixels(3, 10);

    // ── Rows 4-7: Summary banner ──────────────────────────────
    sheet.setRowHeightInPixels(4, 22);
    sheet.setRowHeightInPixels(5, 22);
    sheet.setRowHeightInPixels(6, 22);
    sheet.setRowHeightInPixels(7, 22);

    void summaryHeader(String col, String text) {
      final c = sheet.getRangeByName('${col}4');
      c.setText(text);
      c.cellStyle.bold      = true;
      c.cellStyle.fontSize  = 9;
      c.cellStyle.fontColor = '#FFFFFF';
      c.cellStyle.backColor = '#2E5090';
      c.cellStyle.hAlign    = HAlignType.center;
    }

    void summaryValue(int row, String col, String text,
        {String fontColor = '#FFFFFF'}) {
      final c = sheet.getRangeByName('$col$row');
      c.setText(text);
      c.cellStyle.fontSize  = 9;
      c.cellStyle.fontColor = fontColor;
      c.cellStyle.backColor = '#2E5090';
      c.cellStyle.hAlign    = HAlignType.center;
    }

    void summaryLabel(int row, String text) {
      final c = sheet.getRangeByName('B$row');
      c.setText(text);
      c.cellStyle.bold      = true;
      c.cellStyle.fontSize  = 9;
      c.cellStyle.fontColor = '#FFFFFF';
      c.cellStyle.backColor = '#2E5090';
      c.cellStyle.hAlign    = HAlignType.right;
    }

    // Row A col is always navy bg
    for (var r = 4; r <= 7; r++) {
      sheet.getRangeByName('A$r').cellStyle.backColor = '#2E5090';
    }

    summaryHeader('C', 'Income');
    summaryHeader('D', 'Expenses');
    summaryHeader('E', 'Net');

    summaryLabel(5, 'Total');
    summaryValue(5, 'C', '\$${totalIncome.toStringAsFixed(2)}');
    summaryValue(5, 'D', '\$${totalExpenses.toStringAsFixed(2)}');
    summaryValue(5, 'E',
        '${net >= 0 ? '+' : ''}\$${net.abs().toStringAsFixed(2)}',
        fontColor: net >= 0 ? '#A5D6A7' : '#EF9A9A');

    summaryLabel(6, '% Spent');
    summaryValue(6, 'C', '—');
    summaryValue(6, 'D', pctSpent);
    summaryValue(6, 'E', '—');

    summaryLabel(7, 'Remaining');
    summaryValue(7, 'C', '\$${totalIncome.toStringAsFixed(2)}');
    summaryValue(7, 'D',
        '\$${(totalIncome - totalExpenses).abs().toStringAsFixed(2)}');
    summaryValue(7, 'E', '—');

    // ── Row 8: Spacer ─────────────────────────────────────────
    sheet.setRowHeightInPixels(8, 10);

    // ── Row 9: Column headers ─────────────────────────────────
    sheet.setRowHeightInPixels(9, 28);
    const cols    = ['A', 'B', 'C', 'D', 'E'];
    const headers = ['Date', 'Merchant / Description', 'Category', 'Type', 'Amount'];
    for (var i = 0; i < headers.length; i++) {
      final c = sheet.getRangeByName('${cols[i]}9');
      c.setText(headers[i]);
      c.cellStyle.bold      = true;
      c.cellStyle.fontSize  = 10;
      c.cellStyle.fontColor = '#FFFFFF';
      c.cellStyle.backColor = '#1B3A6B';
      c.cellStyle.hAlign    =
          i == 4 ? HAlignType.right : HAlignType.left;
      c.cellStyle.vAlign    = VAlignType.center;
    }

    // ── Data rows ─────────────────────────────────────────────
    for (var i = 0; i < sorted.length; i++) {
      final t         = sorted[i];
      final row       = i + 10;
      final isExpense = t.type == TransactionType.expense &&
          t.category != TransactionCategory.income;
      final rowBg     = i.isEven ? '#FFFFFF' : '#EEF2F7';

      sheet.setRowHeightInPixels(row, 22);

      void cell(String col, String val,
          {bool right = false, String? color}) {
        final c = sheet.getRangeByName('$col$row');
        c.setText(val);
        c.cellStyle.fontSize  = 10;
        c.cellStyle.backColor = rowBg;
        c.cellStyle.fontColor = color ?? '#1A1A2E';
        c.cellStyle.hAlign    =
            right ? HAlignType.right : HAlignType.left;
        c.cellStyle.vAlign    = VAlignType.center;
        c.cellStyle.borders.bottom.lineStyle = LineStyle.thin;
        c.cellStyle.borders.bottom.color     = '#E0E0E0';
      }

      cell('A', DateFormat('dd MMM yyyy').format(t.date));
      cell('B', t.merchantName);
      cell('C', CategoryMeta.of(t.category).label);
      cell('D', isExpense ? 'Expense' : 'Income',
          color: isExpense ? '#C62828' : '#1B5E20');
      cell('E',
          '${isExpense ? '-' : '+'}\$${t.amount.toStringAsFixed(2)}',
          right: true,
          color: isExpense ? '#C62828' : '#1B5E20');
    }

    // ── Footer: Expense Total ─────────────────────────────────
    final footerRow = sorted.length + 10;
    sheet.setRowHeightInPixels(footerRow, 28);

    for (final col in cols) {
      final c = sheet.getRangeByName('$col$footerRow');
      c.cellStyle.backColor = '#162B52';
      c.cellStyle.fontColor = '#FFFFFF';
      c.cellStyle.bold      = true;
      c.cellStyle.fontSize  = 10;
      c.cellStyle.vAlign    = VAlignType.center;
    }

    sheet.getRangeByName('B$footerRow').setText('Expense Total');
    sheet.getRangeByName('E$footerRow')
      ..setText('-\$${totalExpenses.toStringAsFixed(2)}')
      ..cellStyle.hAlign = HAlignType.right
      ..cellStyle.fontColor = '#EF9A9A';

    final bytes = Uint8List.fromList(workbook.saveAsStream());
    workbook.dispose();
    return bytes;
  }
}

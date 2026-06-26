import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../data/services/export_service.dart';

class ExportSheet extends StatefulWidget {
  final ExportService exportService;
  const ExportSheet({super.key, required this.exportService});

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  int  _selectedYear  = DateTime.now().year;
  int  _selectedMonth = DateTime.now().month;
  bool _loading       = false;

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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: palette.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title row
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: palette.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.table_chart_outlined, color: palette.primary),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Export Expenses',
                  style: AppTextStyles.heading2(palette.textPrimary)),
              Text('Download as Excel spreadsheet',
                  style: AppTextStyles.bodySmall(palette.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 28),

          // Year row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _YearArrow(
                  icon: Icons.chevron_left,
                  onTap: () => setState(() => _selectedYear--),
                  color: palette.textPrimary,
                ),
                Text('$_selectedYear',
                    style: AppTextStyles.heading3(palette.textPrimary)
                        .copyWith(fontSize: 18)),
                _YearArrow(
                  icon: Icons.chevron_right,
                  onTap: _selectedYear < now.year
                      ? () => setState(() => _selectedYear++)
                      : null,
                  color: _selectedYear < now.year
                      ? palette.textPrimary
                      : palette.cardBorder,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Month grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            childAspectRatio: 2.1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(12, (i) {
              final month    = i + 1;
              final isFuture = _selectedYear == now.year && month > now.month;
              final isSel    = _selectedMonth == month;

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () => setState(() => _selectedMonth = month),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSel
                        ? palette.primary
                        : isFuture
                            ? palette.background
                            : palette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel
                          ? palette.primary
                          : palette.cardBorder,
                      width: isSel ? 2 : 1,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _months[i].substring(0, 3),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSel
                          ? Colors.white
                          : isFuture
                              ? palette.cardBorder
                              : palette.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Selected preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: palette.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.insert_drive_file_outlined,
                  color: palette.primary, size: 18),
              const SizedBox(width: 10),
              Text(
                'Flo_Expenses_${_months[_selectedMonth - 1]}_$_selectedYear.xlsx',
                style: AppTextStyles.bodySmall(palette.primary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Export button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _export,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Download ${_months[_selectedMonth - 1]} $_selectedYear',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YearArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _YearArrow(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.palette.cardBorder.withValues(alpha: 0.3),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

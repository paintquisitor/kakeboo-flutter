import 'package:flutter/material.dart';

import '../../core/format/kakebo_format.dart';
import '../../domain/expense_catalog.dart';
import '../../domain/expense_category.dart';
import '../diary/diary_categories.dart';

String reportMoney(BuildContext context, int amount, String currency) =>
    formatMoney(
      amount,
      currencyCode: currency,
      locale: Localizations.localeOf(context),
    );

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.child, this.tint = false});
  final Widget child;
  final bool tint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class ReportAmount extends StatelessWidget {
  const ReportAmount({
    super.key,
    required this.label,
    required this.amount,
    required this.currency,
    this.color,
    this.onTap,
    this.keyName,
  });
  final String label, currency;
  final int amount;
  final Color? color;
  final VoidCallback? onTap;
  final String? keyName;

  @override
  Widget build(BuildContext context) => InkWell(
    key: keyName == null ? null : Key(keyName!),
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            reportMoney(context, amount, currency),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.chevron_right, size: 18),
            ),
        ],
      ),
    ),
  );
}

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
    required this.totals,
    required this.catalog,
    required this.currency,
  });
  final Map<CategoryKey?, int> totals;
  final ExpenseCatalog catalog;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ordered = totals.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = ordered.fold<int>(0, (sum, e) => sum + e.value);
    if (total == 0) {
      return Text(diaryText(context, 'Brak wydatków', 'No expenses'));
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (final item in ordered)
                  Expanded(
                    flex: item.value,
                    child: ColoredBox(color: categoryColor(context, item.key)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in ordered)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: categoryColor(context, item.key),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(categoryLabel(context, item.key, catalog)),
                ),
                Text(
                  '${(item.value * 100 / total).round()}%  ${reportMoney(context, item.value, currency)}',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app/category_icons.dart';
import '../../app/hero_icon.dart';
import '../../core/format/kakebo_format.dart';
import '../../core/time/calendar_date.dart';
import '../../data/kakebo_database.dart';
import '../../data/receipt_attachment_store.dart';
import '../../domain/budget_reports.dart';
import '../../domain/expense_catalog.dart';
import '../../domain/expense_category.dart';
import '../../domain/models.dart';
import '../categories/category_manager_screen.dart';
import 'diary_categories.dart';
import 'expense_editor.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    super.key,
    required this.database,
    required this.selectedDate,
    required this.onSelectDate,
    required this.currency,
    this.receipts,
    this.onOpenReceipt,
    this.recoveredReceipt,
    this.onRecoveredConsumed,
  });

  final KakeboDatabase database;
  final CalendarDate selectedDate;
  final ValueChanged<CalendarDate> onSelectDate;
  final String currency;
  final ReceiptAttachmentStore? receipts;
  final XFile? recoveredReceipt;
  final VoidCallback? onRecoveredConsumed;

  /// Supplied by the receipt feature once a persisted attachment can be opened.
  final ValueChanged<String>? onOpenReceipt;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  KakeboDatabase get database => widget.database;
  CalendarDate get selectedDate => widget.selectedDate;
  ValueChanged<CalendarDate> get onSelectDate => widget.onSelectDate;
  String get currency => widget.currency;
  ReceiptAttachmentStore? get receipts => widget.receipts;
  ValueChanged<String>? get onOpenReceipt => widget.onOpenReceipt;

  XFile? _pendingRecovered;

  @override
  void initState() {
    super.initState();
    _pendingRecovered = widget.recoveredReceipt;
  }

  @override
  void didUpdateWidget(DiaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recoveredReceipt != widget.recoveredReceipt) {
      _pendingRecovered = widget.recoveredReceipt;
    }
  }

  Future<void> _edit(
    BuildContext context,
    ExpenseCatalog catalog, [
    Entry? entry,
    bool pickReceiptOnOpen = false,
    XFile? initialReceipt,
  ]) async {
    final savedDate = await showDialog<CalendarDate>(
      context: context,
      builder: (context) => ExpenseEditor(
        database: database,
        catalog: catalog,
        initialDate: selectedDate,
        entry: entry,
        currency: currency,
        receipts: receipts,
        pickReceiptOnOpen: pickReceiptOnOpen,
        initialReceipt: initialReceipt,
      ),
    );
    if (savedDate != null) onSelectDate(savedDate);
  }

  Future<void> _delete(BuildContext context, Entry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(diaryText(context, 'Usunąć wydatek?', 'Delete expense?')),
        content: Text(
          diaryText(
            context,
            'Usunąć ten wydatek? Tej operacji nie można cofnąć.',
            'Delete this expense? This cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(diaryText(context, 'Anuluj', 'Cancel')),
          ),
          TextButton(
            key: const Key('confirm_expense_delete'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              diaryText(context, 'Usuń', 'Delete'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await database.deleteEntry(entry.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              diaryText(
                context,
                'Nie udało się usunąć wydatku.',
                'Could not delete the expense.',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Entry>>(
    stream: database.watchEntries(),
    builder: (context, entriesSnapshot) => StreamBuilder<List<CustomCategoryRow>>(
      stream: database.watchCategories(),
      builder: (context, categoriesSnapshot) => StreamBuilder<List<CustomSubcategoryRow>>(
        stream: database.watchSubcategories(),
        builder: (context, subcategoriesSnapshot) {
          if (entriesSnapshot.hasError ||
              categoriesSnapshot.hasError ||
              subcategoriesSnapshot.hasError) {
            return Center(
              child: Text(
                diaryText(
                  context,
                  'Nie udało się wczytać dziennika.',
                  'Could not load the journal.',
                ),
              ),
            );
          }
          if (!entriesSnapshot.hasData ||
              !categoriesSnapshot.hasData ||
              !subcategoriesSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final custom = categoriesSnapshot.data!
              .map(
                (row) => CustomCategoryWithSubcategories(
                  CustomCategory(
                    id: row.id,
                    name: row.name,
                    nameKey: row.nameKey,
                    icon: row.icon,
                  ),
                  subcategoriesSnapshot.data!
                      .where((s) => s.categoryId == row.id)
                      .map(
                        (s) => CustomSubcategory(
                          id: s.id,
                          categoryId: s.categoryId,
                          name: s.name,
                          nameKey: s.nameKey,
                        ),
                      ),
                ),
              )
              .toList();
          final catalog = ExpenseCatalog(custom);
          final recovered = _pendingRecovered;
          if (recovered != null) {
            _pendingRecovered = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              widget.onRecoveredConsumed?.call();
              _edit(context, catalog, null, false, recovered);
            });
          }
          final dayEntries =
              entriesSnapshot.data!
                  .where(
                    (entry) =>
                        entry.type == EntryType.expense &&
                        entry.dateEpochDay == selectedDate.epochDay,
                  )
                  .toList()
                ..sort((a, b) => b.id.compareTo(a.id));
          final day = DayReport(selectedDate, dayEntries, catalog);
          final scheme = Theme.of(context).colorScheme;
          final locale = Localizations.localeOf(context);
          final dateValue = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );
          final today = CalendarDate.fromCalendarFields(DateTime.now());
          final formatted = DateFormat(
            'EEEE, d MMMM',
            locale.toLanguageTag(),
          ).format(dateValue);
          final dateLabel = selectedDate == today
              ? diaryText(
                  context,
                  'Dzisiaj, ${DateFormat('d MMMM', locale.toLanguageTag()).format(dateValue)}',
                  'Today, ${DateFormat('d MMMM', locale.toLanguageTag()).format(dateValue)}',
                )
              : '${formatted[0].toUpperCase()}${formatted.substring(1)}';
          return ListView(
            key: const Key('diary_list'),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Card(
                color: scheme.primaryContainer,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          key: const Key('previous_day'),
                          tooltip: diaryText(
                            context,
                            'Poprzedni dzień',
                            'Previous day',
                          ),
                          onPressed: () =>
                              onSelectDate(selectedDate.plusDays(-1)),
                          icon: const HeroIcon('chevron_left', size: 19),
                        ),
                        Expanded(
                          child: Text(
                            dateLabel,
                            key: const Key('diary_day'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        IconButton(
                          key: const Key('next_day'),
                          tooltip: diaryText(
                            context,
                            'Następny dzień',
                            'Next day',
                          ),
                          onPressed: () =>
                              onSelectDate(selectedDate.plusDays(1)),
                          icon: const HeroIcon('chevron_right', size: 19),
                        ),
                      ],
                    ),
                    Divider(
                      height: 1,
                      color: scheme.primary.withValues(alpha: .15),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  diaryText(
                                    context,
                                    'Wydatki tego dnia',
                                    'Spent today',
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatMoney(
                                    day.spent,
                                    currencyCode: currency,
                                    locale: locale,
                                  ),
                                  key: const Key('diary_day_total'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                Text(
                                  _transactionCount(context, dayEntries.length),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: .72),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: HeroIcon(
                              'receipt_percent',
                              size: 26,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: scheme.onPrimaryContainer.withValues(alpha: .28),
                    ),
                    ExpansionTile(
                      key: Key('day_categories_${selectedDate.epochDay}'),
                      title: Text(
                        diaryText(context, 'W tym dniu', 'On this day'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      leading: HeroIcon(
                        'chart_bar',
                        size: 18,
                        color: scheme.primary,
                      ),
                      trailing: Text(
                        formatMoney(
                          day.spent,
                          currencyCode: currency,
                          locale: locale,
                        ),
                        key: const Key('diary_total'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      children: [
                        for (final total in day.categoryTotals.entries.where(
                          (e) => e.value > 0,
                        ))
                          _CategoryTotalRow(
                            key: Key(
                              'day_category_${total.key?.builtIn?.storageKey ?? total.key?.customId ?? 'card'}',
                            ),
                            category: total.key,
                            amount: total.value,
                            catalog: catalog,
                            currency: currency,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                key: const Key('add_expense'),
                onPressed: () => _edit(context, catalog),
                icon: const HeroIcon('plus_circle', size: 21),
                label: Text(diaryText(context, 'Dodaj wydatek', 'Add expense')),
              ),
              if (receipts != null) ...[
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  key: const Key('add_from_receipt'),
                  onPressed: () => _edit(context, catalog, null, true),
                  icon: const HeroIcon('receipt_percent', size: 20),
                  label: Text(
                    diaryText(
                      context,
                      'Dodaj na podstawie paragonu',
                      'Add from receipt',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      diaryText(context, 'Transakcje', 'Transactions'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            CategoryManagerScreen(database: database),
                      ),
                    ),
                    icon: const HeroIcon('squares_2x2', size: 17),
                    label: Text(diaryText(context, 'Kategorie', 'Categories')),
                  ),
                ],
              ),
              Divider(
                key: const Key('diary_section_divider'),
                height: 16,
                color: scheme.outlineVariant,
              ),
              if (dayEntries.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      diaryText(
                        context,
                        'Nie masz jeszcze wydatków w tym dniu.',
                        'No expenses recorded for this day.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < dayEntries.length; i++) ...[
                        DiaryTransactionRow(
                          entry: dayEntries[i],
                          catalog: catalog,
                          currency: currency,
                          onEdit: () => _edit(context, catalog, dayEntries[i]),
                          onDelete: () => _delete(context, dayEntries[i]),
                          onOpenReceipt: onOpenReceipt,
                        ),
                        if (i < dayEntries.length - 1)
                          Divider(
                            height: 1,
                            indent: 62,
                            color: scheme.outlineVariant,
                          ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                diaryText(
                  context,
                  'Koszty stałe z Planu są już uwzględnione w budżecie.',
                  'Fixed costs from the Plan are already included in the budget.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    ),
  );
}

String _transactionCount(BuildContext context, int count) {
  if (Localizations.localeOf(context).languageCode == 'en') {
    return '$count ${count == 1 ? 'transaction' : 'transactions'}';
  }
  final word = count == 1
      ? 'transakcja'
      : count % 10 >= 2 &&
            count % 10 <= 4 &&
            (count % 100 < 12 || count % 100 > 14)
      ? 'transakcje'
      : 'transakcji';
  return '$count $word';
}

class _CategoryTotalRow extends StatelessWidget {
  const _CategoryTotalRow({
    super.key,
    required this.category,
    required this.amount,
    required this.catalog,
    required this.currency,
  });
  final CategoryKey? category;
  final int amount;
  final ExpenseCatalog catalog;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(context, category);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          HeroIcon(
            categoryIconAsset(category, catalog),
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(categoryLabel(context, category, catalog))),
          Text(
            formatMoney(
              amount,
              currencyCode: currency,
              locale: Localizations.localeOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryTransactionRow extends StatelessWidget {
  const DiaryTransactionRow({
    super.key,
    required this.entry,
    required this.catalog,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    this.onOpenReceipt,
  });
  final Entry entry;
  final ExpenseCatalog catalog;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String>? onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final category = catalog.categoryOf(entry);
    final subcategory = entry.subcategory == null
        ? catalog.subcategories[entry.customSubcategoryId]?.name ??
              categoryLabel(context, null, catalog)
        : subcategoryLabel(context, entry.subcategory!);
    final categoryPath = category == null
        ? subcategory
        : '${categoryLabel(context, category, catalog)} · $subcategory';
    final icon = entry.subcategory?.icon ?? categoryIconId(category, catalog);
    final color = categoryColor(context, category);
    final receiptName = entry.receiptName;
    return InkWell(
      key: Key('expense_${entry.id}'),
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: StoredCategoryIcon(icon, size: 21, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.note.isEmpty ? subcategory : entry.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (receiptName != null && onOpenReceipt != null)
                          IconButton(
                            key: Key('receipt_${entry.id}'),
                            tooltip: diaryText(
                              context,
                              'Pokaż paragon',
                              'View receipt',
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 25,
                              height: 25,
                            ),
                            onPressed: () => onOpenReceipt!(receiptName),
                            icon: HeroIcon(
                              'paper_clip',
                              size: 17,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        const SizedBox(width: 5),
                        Text(
                          formatMoney(
                            entry.amountGrosz,
                            currencyCode: currency,
                            locale: Localizations.localeOf(context),
                          ),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            categoryPath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                        IconButton(
                          key: Key('delete_expense_${entry.id}'),
                          tooltip: diaryText(
                            context,
                            'Usuń wydatek',
                            'Delete expense',
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 25,
                            height: 25,
                          ),
                          onPressed: onDelete,
                          icon: HeroIcon(
                            'trash',
                            size: 17,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

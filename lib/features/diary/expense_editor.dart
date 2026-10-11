import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/category_icons.dart';
import '../../app/hero_icon.dart';
import '../../core/time/calendar_date.dart';
import '../../core/documents/local_document_reader.dart';
import '../../data/kakebo_database.dart';
import '../../data/receipt_attachment_store.dart';
import '../../domain/expense_category.dart';
import '../../domain/expense_catalog.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/receipt_parser.dart';
import 'diary_categories.dart';

class ExpenseEditor extends StatefulWidget {
  const ExpenseEditor({
    super.key,
    required this.database,
    required this.catalog,
    required this.initialDate,
    this.entry,
    required this.currency,
    this.receipts,
    this.initialReceipt,
    this.pickReceiptOnOpen = false,
    this.documentReader,
  });

  final KakeboDatabase database;
  final ExpenseCatalog catalog;
  final CalendarDate initialDate;
  final Entry? entry;
  final String currency;
  final ReceiptAttachmentStore? receipts;
  final XFile? initialReceipt;
  final bool pickReceiptOnOpen;
  final LocalDocumentReader? documentReader;

  @override
  State<ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends State<ExpenseEditor> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.entry == null ? '' : amountInput(widget.entry!.amountGrosz),
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.entry?.note ?? '',
  );
  late CalendarDate _date = widget.entry == null
      ? widget.initialDate
      : CalendarDate.fromEpochDay(widget.entry!.dateEpochDay);
  late ExpenseSubcategory? _subcategory = widget.entry?.subcategory;
  late int? _customSubcategoryId = widget.entry?.customSubcategoryId;
  bool _submitted = false;
  bool _saving = false;
  bool _saveError = false;
  XFile? _receipt;
  bool _readingReceipt = false;
  String? _receiptError;

  @override
  void initState() {
    super.initState();
    _receipt = widget.initialReceipt;
    if (widget.pickReceiptOnOpen || _receipt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_receipt != null) {
          _readReceipt();
        } else {
          _chooseReceipt();
        }
      });
    }
  }

  Future<void> _chooseReceipt() async {
    final receipts = widget.receipts;
    if (receipts == null || _saving || _readingReceipt) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const HeroIcon('camera', size: 22),
              title: Text(diaryText(context, 'Zrób zdjęcie', 'Take photo')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const HeroIcon('document_arrow_up', size: 22),
              title: Text(
                diaryText(context, 'Wybierz plik zdjęcia', 'Choose image file'),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final image = await receipts.pick(source);
      if (image == null || !mounted) return;
      setState(() {
        _receipt = image;
        _receiptError = null;
      });
      await _readReceipt();
    } catch (_) {
      if (mounted) {
        setState(
          () => _receiptError = diaryText(
            context,
            'Nie udało się otworzyć zdjęcia.',
            'Could not open the image.',
          ),
        );
      }
    }
  }

  Future<void> _readReceipt() async {
    final image = _receipt;
    if (image == null || _readingReceipt || !mounted) return;
    setState(() {
      _readingReceipt = true;
      _receiptError = null;
    });
    try {
      final text = await (widget.documentReader ?? LocalDocumentReader())
          .readReceipt(image.path);
      final suggestion = parseReceipt(text);
      if (!mounted) return;
      if (!suggestion.hasValues) {
        setState(
          () => _receiptError = diaryText(
            context,
            'Nie rozpoznano danych. Uzupełnij wydatek ręcznie.',
            'No data recognized. Complete the expense manually.',
          ),
        );
        return;
      }
      setState(() => _readingReceipt = false);
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(diaryText(context, 'Dane z paragonu', 'Receipt details')),
          content: Text(
            [
              if (suggestion.merchant != null) suggestion.merchant!,
              if (suggestion.amountGrosz != null)
                amountInput(suggestion.amountGrosz!),
              if (suggestion.date != null)
                '${suggestion.date!.day}.${suggestion.date!.month}.${suggestion.date!.year}',
            ].join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(diaryText(context, 'Odrzuć', 'Discard')),
            ),
            FilledButton(
              key: const Key('apply_receipt_suggestion'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(diaryText(context, 'Użyj danych', 'Use details')),
            ),
          ],
        ),
      );
      if (accepted == true && mounted) {
        setState(() {
          if (suggestion.amountGrosz != null) {
            _amount.text = amountInput(suggestion.amountGrosz!);
          }
          if (suggestion.date != null) _date = suggestion.date!;
          if (suggestion.merchant != null) _note.text = suggestion.merchant!;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _receiptError = diaryText(
            context,
            'Nie udało się odczytać paragonu. Możesz wpisać dane ręcznie.',
            'Could not read the receipt. You can enter details manually.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _readingReceipt = false);
    }
  }

  CategoryKey? get _selectedCategory {
    if (_subcategory != null) return _subcategory!.category.key;
    final custom = widget.catalog.subcategories[_customSubcategoryId];
    return custom == null ? null : CategoryKey.custom(custom.categoryId);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (picked != null && mounted) {
      setState(
        () => _date = CalendarDate(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<void> _chooseSubcategory(CategoryKey category) async {
    final selected = await showModalBottomSheet<_SubcategoryChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SubcategorySheet(
        category: category,
        catalog: widget.catalog,
        selectedBuiltIn: _subcategory,
        selectedCustomId: _customSubcategoryId,
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _subcategory = selected.builtIn;
        _customSubcategoryId = selected.customId;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final amount = parseGrosz(_amount.text);
    setState(() {
      _submitted = true;
      _saveError = false;
    });
    if (amount == null || amount <= 0 || _selectedCategory == null) return;
    setState(() => _saving = true);
    String? newReceiptName;
    try {
      final old = widget.entry;
      final keepPlanLink =
          old?.plannedItemId != null &&
          CalendarDate.fromEpochDay(old!.dateEpochDay).yearMonth ==
              _date.yearMonth;
      if (_receipt != null) {
        newReceiptName = await widget.receipts!.persist(_receipt!);
      }
      await widget.database.saveEntry(
        Entry(
          id: old?.id ?? 0,
          amountGrosz: amount,
          type: EntryType.expense,
          dateEpochDay: _date.epochDay,
          note: _note.text.trim(),
          subcategory: _subcategory,
          customSubcategoryId: _customSubcategoryId,
          plannedItemId: keepPlanLink ? old.plannedItemId : null,
          receiptName: newReceiptName ?? old?.receiptName,
        ),
      );
      if (mounted) Navigator.pop(context, _date);
    } catch (_) {
      if (newReceiptName != null) {
        try {
          await widget.receipts!.store.receiptFile(newReceiptName).delete();
        } catch (_) {}
      }
      if (mounted) setState(() => _saveError = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedCategory;
    final custom = widget.catalog.subcategories[_customSubcategoryId];
    final selectedName = _subcategory == null
        ? custom?.name
        : subcategoryLabel(context, _subcategory!);
    final selectedIcon =
        _subcategory?.icon ?? categoryIconId(selected, widget.catalog);
    final scheme = Theme.of(context).colorScheme;
    final amountInvalid =
        _submitted &&
        (parseGrosz(_amount.text) == null || parseGrosz(_amount.text)! <= 0);
    return AlertDialog(
      title: Text(
        widget.entry == null
            ? diaryText(context, 'Dodaj wydatek', 'Add expense')
            : diaryText(context, 'Edytuj wydatek', 'Edit expense'),
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('expense_amount'),
                controller: _amount,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: diaryText(
                    context,
                    'Kwota (${widget.currency})',
                    'Amount (${widget.currency})',
                  ),
                  errorText: amountInvalid
                      ? diaryText(
                          context,
                          'Wpisz kwotę większą od zera.',
                          'Enter an amount greater than zero.',
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('expense_date'),
                onPressed: _saving ? null : _chooseDate,
                icon: const HeroIcon('calendar_days', size: 18),
                label: Text(
                  '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                ),
              ),
              const SizedBox(height: 12),
              if (selected != null && selectedName != null) ...[
                InkWell(
                  key: const Key('selected_subcategory'),
                  onTap: _saving
                      ? null
                      : () => setState(() {
                          _subcategory = null;
                          _customSubcategoryId = null;
                        }),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor(
                        context,
                        selected,
                      ).withValues(alpha: .10),
                      border: Border.all(
                        color: categoryColor(
                          context,
                          selected,
                        ).withValues(alpha: .45),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        StoredCategoryIcon(
                          selectedIcon,
                          size: 27,
                          color: categoryColor(context, selected),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryLabel(
                                  context,
                                  selected,
                                  widget.catalog,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                selectedName,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        Text(diaryText(context, 'Zmień', 'Change')),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  diaryText(context, 'Wybierz kategorię', 'Choose category'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final key in widget.catalog.keys)
                          SizedBox(
                            width: width,
                            child: OutlinedButton(
                              key: Key(
                                'category_${key.builtIn?.storageKey ?? key.customId}',
                              ),
                              onPressed: _saving
                                  ? null
                                  : () => _chooseSubcategory(key),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                              ),
                              child: Column(
                                children: [
                                  StoredCategoryIcon(
                                    categoryIconId(key, widget.catalog),
                                    size: 27,
                                    color: categoryColor(context, key),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    categoryLabel(context, key, widget.catalog),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
              if (_submitted && selected == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    diaryText(
                      context,
                      'Wybierz kategorię i podkategorię.',
                      'Choose a category and subcategory.',
                    ),
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('expense_note'),
                controller: _note,
                enabled: !_saving,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: diaryText(
                    context,
                    'Opis (opcjonalny)',
                    'Description (optional)',
                  ),
                ),
              ),
              if (widget.receipts != null) ...[
                OutlinedButton.icon(
                  key: const Key('choose_receipt'),
                  onPressed: _saving || _readingReceipt ? null : _chooseReceipt,
                  icon: const HeroIcon('paper_clip', size: 18),
                  label: Text(
                    diaryText(
                      context,
                      _receipt == null ? 'Dodaj paragon' : 'Zmień paragon',
                      _receipt == null ? 'Attach receipt' : 'Replace receipt',
                    ),
                  ),
                ),
                if (_receipt != null) ...[
                  Image.file(
                    File(_receipt!.path),
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                  TextButton.icon(
                    key: const Key('read_receipt'),
                    onPressed: _readingReceipt || _saving ? null : _readReceipt,
                    icon: const HeroIcon('receipt_percent', size: 18),
                    label: Text(
                      diaryText(context, 'Odczytaj paragon', 'Read receipt'),
                    ),
                  ),
                ],
                if (_readingReceipt) const LinearProgressIndicator(),
                if (_receiptError != null)
                  Text(_receiptError!, style: TextStyle(color: scheme.error)),
              ],
              if (_saveError)
                Text(
                  diaryText(
                    context,
                    'Nie udało się zapisać wydatku.',
                    'Could not save the expense.',
                  ),
                  style: TextStyle(color: scheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(diaryText(context, 'Anuluj', 'Cancel')),
        ),
        FilledButton(
          key: const Key('save_expense'),
          onPressed: _saving ? null : _save,
          child: Text(
            _saving
                ? diaryText(context, 'Zapisywanie…', 'Saving…')
                : diaryText(context, 'Zapisz', 'Save'),
          ),
        ),
      ],
    );
  }
}

final class _SubcategoryChoice {
  const _SubcategoryChoice(this.builtIn, this.customId);
  final ExpenseSubcategory? builtIn;
  final int? customId;
}

class _SubcategorySheet extends StatelessWidget {
  const _SubcategorySheet({
    required this.category,
    required this.catalog,
    required this.selectedBuiltIn,
    required this.selectedCustomId,
  });
  final CategoryKey category;
  final ExpenseCatalog catalog;
  final ExpenseSubcategory? selectedBuiltIn;
  final int? selectedCustomId;

  @override
  Widget build(BuildContext context) {
    final choices = <(ExpenseSubcategory?, int?, String, String)>[
      for (final sub
          in category.builtIn?.subcategories ?? <ExpenseSubcategory>[])
        (sub, null, subcategoryLabel(context, sub), sub.icon),
      for (final sub in catalog.subcategories.values.where(
        (s) => s.categoryId == category.customId,
      ))
        (null, sub.id, sub.name, categoryIconId(category, catalog)),
    ];
    final color = categoryColor(context, category);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              diaryText(context, 'Wybierz podkategorię', 'Choose subcategory'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(categoryLabel(context, category, catalog)),
            const SizedBox(height: 14),
            Flexible(
              child: GridView.builder(
                key: const Key('subcategory_grid'),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 90,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  final choice = choices[index];
                  final selected =
                      choice.$1 == selectedBuiltIn &&
                      choice.$2 == selectedCustomId;
                  return OutlinedButton(
                    key: Key(
                      'subcategory_${choice.$1?.storageKey ?? choice.$2}',
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      _SubcategoryChoice(choice.$1, choice.$2),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selected
                          ? color.withValues(alpha: .16)
                          : null,
                      side: BorderSide(
                        color: selected
                            ? color
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StoredCategoryIcon(choice.$4, size: 27, color: color),
                        const SizedBox(height: 5),
                        Text(
                          choice.$3,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (choices.isEmpty)
              Text(
                diaryText(
                  context,
                  'Najpierw dodaj podkategorię w menedżerze kategorii.',
                  'Add a subcategory in category management first.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

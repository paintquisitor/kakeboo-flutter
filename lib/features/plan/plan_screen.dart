import 'package:flutter/material.dart';

import '../../app/category_icons.dart';
import '../../app/hero_icon.dart';
import '../../core/format/kakebo_format.dart';
import '../../core/time/calendar_date.dart';
import '../../data/kakebo_database.dart';
import '../../domain/budget_reports.dart';
import '../../domain/fixed_expense_catalog.dart';
import '../../domain/models.dart';
import '../../domain/money.dart' as money;
import '../categories/category_manager_screen.dart';

String planText(BuildContext context, String pl, String en) =>
    Localizations.localeOf(context).languageCode == 'en' ? en : pl;

String _money(BuildContext context, int amount, String currency) => formatMoney(
  amount,
  currencyCode: currency,
  locale: Localizations.localeOf(context),
);

class PlanScreen extends StatelessWidget {
  const PlanScreen({
    super.key,
    required this.month,
    required this.database,
    required this.currency,
  });

  final YearMonth month;
  final KakeboDatabase database;
  final String currency;

  bool get _isFuture =>
      month.compareTo(YearMonth(DateTime.now().year, DateTime.now().month)) > 0;

  Future<void> _addItem(BuildContext context, EntryType type) async {
    FixedExpensePreset? preset;
    if (type == EntryType.expense) {
      preset = await showModalBottomSheet<FixedExpensePreset>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => const _FixedPresetPicker(),
      );
      if (preset == null || !context.mounted) return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => _ItemEditor(
        database: database,
        month: month,
        type: type,
        preset: preset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<MonthlyPlanWithItems?>(
    stream: database.watchMonth(month),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text(
            planText(
              context,
              'Nie udało się wczytać planu.',
              'Could not load the plan.',
            ),
          ),
        );
      }
      if (!snapshot.hasData &&
          snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final plan = snapshot.data ?? MonthlyPlanWithItems.empty(month);
      final totals = planTotals(plan);
      final scheme = Theme.of(context).colorScheme;
      final income =
          plan.items.where((i) => i.type == EntryType.income).toList()
            ..sort((a, b) => a.dateEpochDay.compareTo(b.dateEpochDay));
      final fixed =
          plan.items.where((i) => i.type == EntryType.expense).toList()
            ..sort((a, b) => a.dateEpochDay.compareTo(b.dateEpochDay));
      return ListView(
        key: const Key('plan_list'),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            color: scheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planText(context, 'Do dyspozycji', 'Available'),
                    style: TextStyle(
                      color: scheme.onPrimary.withValues(alpha: .82),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _money(context, _isFuture ? 0 : totals.available, currency),
                    key: const Key('plan_available'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    planText(
                      context,
                      'Wpływy − stałe wydatki − cel oszczędnościowy',
                      'Income − fixed expenses − savings goal',
                    ),
                    style: TextStyle(
                      color: scheme.onPrimary.withValues(alpha: .82),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  title: planText(context, 'Wpływy', 'Income'),
                  value: _money(
                    context,
                    _isFuture ? 0 : totals.income,
                    currency,
                  ),
                  color: scheme.primary,
                  icon: 'arrow_down_circle',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  title: planText(context, 'Stałe wydatki', 'Fixed expenses'),
                  value: _money(
                    context,
                    _isFuture ? 0 : totals.fixedExpenses,
                    currency,
                  ),
                  color: scheme.error,
                  icon: 'arrow_up_circle',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              key: const Key('edit_goals'),
              leading: const HeroIcon('target'),
              title: Text(
                planText(context, 'Cel na ten miesiąc', 'This month’s goal'),
              ),
              subtitle: Text(
                plan.plan.resolutions.isEmpty
                    ? planText(
                        context,
                        'Dodaj postanowienie i kwotę oszczędności',
                        'Add a resolution and savings amount',
                      )
                    : plan.plan.resolutions,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(_money(context, plan.plan.savingsGrosz, currency)),
              onTap: _isFuture
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      builder: (context) =>
                          _GoalsEditor(database: database, plan: plan.plan),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionTitle(
            title: planText(context, 'Stałe wydatki', 'Fixed expenses'),
            onAdd: _isFuture
                ? null
                : () => _addItem(context, EntryType.expense),
          ),
          for (final item in fixed)
            _PlannedRow(
              item: item,
              currency: currency,
              onTap: _isFuture
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      builder: (context) => _ItemEditor(
                        database: database,
                        month: month,
                        type: EntryType.expense,
                        item: item,
                      ),
                    ),
            ),
          if (fixed.isEmpty)
            _EmptyText(
              planText(context, 'Brak stałych wydatków', 'No fixed expenses'),
            ),
          const SizedBox(height: 12),
          _SectionTitle(
            title: planText(context, 'Wpływy', 'Income'),
            onAdd: _isFuture ? null : () => _addItem(context, EntryType.income),
          ),
          for (final item in income)
            _PlannedRow(
              item: item,
              currency: currency,
              onTap: _isFuture
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      builder: (context) => _ItemEditor(
                        database: database,
                        month: month,
                        type: EntryType.income,
                        item: item,
                      ),
                    ),
            ),
          if (income.isEmpty)
            _EmptyText(planText(context, 'Brak wpływów', 'No income')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => CategoryManagerScreen(database: database),
              ),
            ),
            icon: const HeroIcon('squares_2x2', size: 19),
            label: Text(
              planText(context, 'Zarządzaj kategoriami', 'Manage categories'),
            ),
          ),
          if (_isFuture)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                planText(
                  context,
                  'Plan pojawi się po rozpoczęciu tego miesiąca.',
                  'The plan will appear when this month begins.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String title, value, icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroIcon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onAdd});
  final String title;
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      IconButton(
        onPressed: onAdd,
        icon: const HeroIcon('plus_circle'),
        tooltip: planText(context, 'Dodaj', 'Add'),
      ),
    ],
  );
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _PlannedRow extends StatelessWidget {
  const _PlannedRow({
    required this.item,
    required this.currency,
    required this.onTap,
  });
  final PlannedItem item;
  final String currency;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final due = item.isDueIn();
    final next = item.nextDueMonth(item.month);
    final color = item.type == EntryType.income
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Card(
      child: ListTile(
        key: Key('plan_item_${item.id}'),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: StoredCategoryIcon(item.icon, color: color),
        ),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          due
              ? '${CalendarDate.fromEpochDay(item.dateEpochDay).day} · '
                    '${switch (item.recurrence) {
                      PlanRecurrence.monthly => planText(context, 'Co miesiąc', 'Monthly'),
                      PlanRecurrence.quarterly => planText(context, 'Co kwartał', 'Quarterly'),
                      PlanRecurrence.yearly => planText(context, 'Co rok', 'Yearly'),
                    }}'
              : '${planText(context, 'Nie w tym miesiącu', 'Not due this month')} · '
                    '${planText(context, 'następna płatność', 'next payment')} '
                    '${formatMonth(DateTime(next.year, next.month), Localizations.localeOf(context))}',
        ),
        trailing: Text(
          _money(context, item.amountGrosz, currency),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: due ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FixedPresetPicker extends StatefulWidget {
  const _FixedPresetPicker();
  @override
  State<_FixedPresetPicker> createState() => _FixedPresetPickerState();
}

class _FixedPresetPickerState extends State<_FixedPresetPicker> {
  FixedExpenseGroup? selected;
  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  if (selected != null)
                    IconButton(
                      onPressed: () => setState(() => selected = null),
                      icon: const HeroIcon('chevron_left'),
                    ),
                  Expanded(
                    child: Text(
                      selected == null
                          ? planText(
                              context,
                              'Wybierz grupę wydatku',
                              'Choose expense group',
                            )
                          : selected!.label(language),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 3,
                childAspectRatio: .95,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: selected == null
                    ? [
                        for (final group in fixedExpenseGroups)
                          _PickerTile(
                            icon: group.icon,
                            title: group.label(language),
                            onTap: () => setState(() => selected = group),
                          ),
                      ]
                    : [
                        for (final preset in fixedExpensePresets.where(
                          (p) => p.group == selected!.key,
                        ))
                          _PickerTile(
                            icon: preset.icon,
                            title: preset.label(language),
                            onTap: () => Navigator.pop(context, preset),
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

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final String icon, title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StoredCategoryIcon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _GoalsEditor extends StatefulWidget {
  const _GoalsEditor({required this.database, required this.plan});
  final KakeboDatabase database;
  final MonthlyPlan plan;
  @override
  State<_GoalsEditor> createState() => _GoalsEditorState();
}

class _GoalsEditorState extends State<_GoalsEditor> {
  late final amount = TextEditingController(
    text: money.amountInput(widget.plan.savingsGrosz),
  );
  late final resolutions = TextEditingController(text: widget.plan.resolutions);
  bool saving = false;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    resolutions.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final parsed = money.parseGrosz(amount.text);
    if (parsed == null) {
      setState(
        () => error = planText(
          context,
          'Podaj poprawną kwotę.',
          'Enter a valid amount.',
        ),
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.database.savePlan(
        MonthlyPlan(
          month: widget.plan.month,
          savingsGrosz: parsed,
          resolutions: resolutions.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = planText(
            context,
            'Nie udało się zapisać celu.',
            'Could not save the goal.',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(planText(context, 'Cel miesiąca', 'Monthly goal')),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: planText(
                context,
                'Cel oszczędnościowy',
                'Savings goal',
              ),
            ),
          ),
          TextField(
            controller: resolutions,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: planText(context, 'Postanowienia', 'Resolutions'),
            ),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: Text(planText(context, 'Anuluj', 'Cancel')),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: Text(planText(context, 'Zapisz', 'Save')),
      ),
    ],
  );
}

class _ItemEditor extends StatefulWidget {
  const _ItemEditor({
    required this.database,
    required this.month,
    required this.type,
    this.item,
    this.preset,
  });
  final KakeboDatabase database;
  final YearMonth month;
  final EntryType type;
  final PlannedItem? item;
  final FixedExpensePreset? preset;
  @override
  State<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<_ItemEditor> {
  late final title = TextEditingController(
    text:
        widget.item?.title ??
        (widget.preset?.custom == true ? '' : widget.preset?.label('pl') ?? ''),
  );
  late final amount = TextEditingController(
    text: widget.item == null
        ? ''
        : money.amountInput(widget.item!.amountGrosz),
  );
  late int day = widget.item == null
      ? (widget.month == YearMonth(DateTime.now().year, DateTime.now().month)
            ? DateTime.now().day
            : 1)
      : CalendarDate.fromEpochDay(widget.item!.dateEpochDay).day;
  late PlanRecurrence recurrence =
      widget.item?.recurrence ?? PlanRecurrence.monthly;
  late String icon =
      widget.item?.icon ??
      widget.preset?.icon ??
      (widget.type == EntryType.income ? 'CASH' : 'WALLET');
  bool saving = false;
  String? error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.item == null &&
        widget.preset != null &&
        !widget.preset!.custom &&
        title.text == widget.preset!.label('pl')) {
      title.text = widget.preset!.label(
        Localizations.localeOf(context).languageCode,
      );
    }
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final parsed = money.parseGrosz(amount.text);
    if (title.text.trim().isEmpty || parsed == null || parsed == 0) {
      setState(
        () => error = planText(
          context,
          'Podaj nazwę i kwotę większą od zera.',
          'Enter a name and an amount greater than zero.',
        ),
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.database.transaction(() async {
        if (await widget.database.findMonth(widget.month) == null) {
          await widget.database.savePlan(MonthlyPlan(month: widget.month));
        }
        await widget.database.savePlannedItem(
          PlannedItem(
            id: widget.item?.id ?? 0,
            month: widget.month,
            type: widget.type,
            title: title.text.trim(),
            amountGrosz: parsed,
            dateEpochDay: widget.month.atDay(day).epochDay,
            recurrence: recurrence,
            recurrenceAnchorMonth:
                widget.item != null && widget.item!.recurrence == recurrence
                ? widget.item!.recurrenceAnchorMonth
                : widget.month,
            icon: icon,
          ),
        );
      });
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = planText(
            context,
            'Nie udało się zapisać pozycji.',
            'Could not save this item.',
          );
        });
      }
    }
  }

  Future<void> remove() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.database.deletePlannedItem(widget.item!.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = planText(
            context,
            'Nie można usunąć pozycji powiązanej z płatnością.',
            'Cannot delete an item linked to a payment.',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.item == null
          ? planText(context, 'Dodaj pozycję', 'Add item')
          : planText(context, 'Edytuj pozycję', 'Edit item'),
    ),
    content: SizedBox(
      width: 360,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: planText(context, 'Nazwa', 'Name'),
              ),
            ),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: planText(context, 'Kwota', 'Amount'),
              ),
            ),
            DropdownButtonFormField<int>(
              initialValue: day,
              decoration: InputDecoration(
                labelText: planText(context, 'Dzień miesiąca', 'Day of month'),
              ),
              items: [
                for (var d = 1; d <= widget.month.lengthOfMonth; d++)
                  DropdownMenuItem(value: d, child: Text('$d')),
              ],
              onChanged: saving
                  ? null
                  : (value) {
                      if (value != null) setState(() => day = value);
                    },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(planText(context, 'Częstotliwość', 'Frequency')),
            ),
            SegmentedButton<PlanRecurrence>(
              segments: [
                ButtonSegment(
                  value: PlanRecurrence.monthly,
                  label: Text(planText(context, 'Miesiąc', 'Month')),
                ),
                ButtonSegment(
                  value: PlanRecurrence.quarterly,
                  label: Text(planText(context, 'Kwartał', 'Quarter')),
                ),
                ButtonSegment(
                  value: PlanRecurrence.yearly,
                  label: Text(planText(context, 'Rok', 'Year')),
                ),
              ],
              selected: {recurrence},
              onSelectionChanged: saving
                  ? null
                  : (values) => setState(() => recurrence = values.first),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: saving
                  ? null
                  : () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => IconPicker(selected: icon),
                      );
                      if (result != null && mounted) {
                        setState(() => icon = result);
                      }
                    },
              icon: StoredCategoryIcon(icon),
              label: Text(planText(context, 'Wybierz ikonę', 'Choose icon')),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      if (widget.item != null)
        IconButton(
          key: const Key('delete_plan_item'),
          onPressed: saving ? null : remove,
          icon: const HeroIcon('trash'),
          tooltip: planText(context, 'Usuń', 'Delete'),
        ),
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: Text(planText(context, 'Anuluj', 'Cancel')),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: Text(planText(context, 'Zapisz', 'Save')),
      ),
    ],
  );
}

class IconPicker extends StatefulWidget {
  const IconPicker({super.key, required this.selected});
  final String selected;
  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final icons = categoryIconOptions
        .where(
          (option) => option
              .label(language)
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
    return AlertDialog(
      title: Text(planText(context, 'Wybierz ikonę', 'Choose icon')),
      content: SizedBox(
        width: 360,
        height: 420,
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: planText(context, 'Szukaj ikony', 'Search icons'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1,
                children: [
                  for (final option in icons)
                    _PickerTile(
                      icon: option.key,
                      title: option.label(language),
                      onTap: () => Navigator.pop(context, option.key),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(planText(context, 'Anuluj', 'Cancel')),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';

import '../core/format/kakebo_format.dart';
import '../core/time/calendar_date.dart';
import '../domain/plan_lifecycle.dart';
import '../data/receipt_attachment_store.dart';
import '../features/diary/diary_screen.dart';
import '../features/balance/balance_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/weeks/weeks_screen.dart';
import 'app_settings_controller.dart';
import 'hero_icon.dart';
import 'kakebo_theme.dart';

class KakeboShell extends StatefulWidget {
  const KakeboShell({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<KakeboShell> createState() => _KakeboShellState();
}

class _KakeboShellState extends State<KakeboShell> with WidgetsBindingObserver {
  late int tab = widget.settings.settings.startTab;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  CalendarDate diaryDate = CalendarDate.fromCalendarFields(DateTime.now());
  bool balanceYearMode = false;
  Timer? _dayTimer;
  XFile? _recoveredReceipt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activateMonth();
    _recoverReceipt();
  }

  Future<void> _recoverReceipt() async {
    final store = widget.settings.store;
    if (store == null) return;
    try {
      final image = await ReceiptAttachmentStore(store).recoverLostImage();
      if (image != null && mounted) {
        setState(() {
          _recoveredReceipt = image;
          tab = 1;
        });
      }
    } catch (_) {
      // Recovery errors never create an attachment or a financial entry.
    }
  }

  void _activateMonth() {
    final now = DateTime.now();
    final nextCurrentMonth = DateTime(now.year, now.month);
    if (nextCurrentMonth != _currentMonth) {
      if (month == _currentMonth) {
        setState(() {
          month = nextCurrentMonth;
          if (diaryDate.yearMonth ==
              YearMonth(_currentMonth.year, _currentMonth.month)) {
            diaryDate = CalendarDate.fromCalendarFields(now);
          }
        });
      }
      _currentMonth = nextCurrentMonth;
    }
    final db = widget.settings.store?.database;
    if (db != null) {
      PlanLifecycle(db, const SystemDateSource()).activateCurrentMonth();
    }
    _dayTimer?.cancel();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _dayTimer = Timer(
      nextDay.difference(now) + const Duration(seconds: 1),
      _activateMonth,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _activateMonth();
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _changeMonth(int offset) {
    setState(() {
      month = DateTime(
        month.year,
        month.month + (tab == 3 && balanceYearMode ? offset * 12 : offset),
      );
      if (tab == 1) {
        final target = YearMonth(month.year, month.month);
        diaryDate = target.atDay(diaryDate.day.clamp(1, target.lengthOfMonth));
      }
    });
  }

  void _selectDiaryDate(CalendarDate date) {
    setState(() {
      diaryDate = date;
      month = DateTime(date.year, date.month);
    });
  }

  void _selectTab(int value) {
    setState(() {
      tab = value;
      if (value == 1 &&
          diaryDate.yearMonth != YearMonth(month.year, month.month)) {
        diaryDate = YearMonth(month.year, month.month).firstDay;
      }
    });
  }

  Future<void> _openReceipt(String name) async {
    final store = widget.settings.store;
    if (store == null) return;
    try {
      final image = store.receiptFile(name);
      if (!await image.exists()) {
        throw const FileSystemException('Missing receipt');
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => _ReceiptPreview(image: image),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nie udało się otworzyć paragonu. / Could not open receipt.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.plan,
      l10n.diary,
      l10n.weeks,
      l10n.balance,
      l10n.profile,
    ];
    final titles = [
      l10n.planMonth,
      l10n.diary,
      l10n.weeks,
      l10n.balance,
      l10n.profile,
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(
              title: titles[tab],
              month: tab == 4 ? null : month,
              periodLabel: tab == 3 && balanceYearMode ? '${month.year}' : null,
              onPrevious: () => _changeMonth(-1),
              onNext: () => _changeMonth(1),
              onOpenProfile: () => setState(() => tab = 4),
            ),
            Expanded(
              child: tab == 4
                  ? _SettingsPreview(settings: widget.settings)
                  : tab == 0 && widget.settings.store != null
                  ? PlanScreen(
                      key: ValueKey('${month.year}-${month.month}'),
                      month: YearMonth(month.year, month.month),
                      database: widget.settings.store!.database,
                      currency: widget.settings.settings.currency ?? 'PLN',
                    )
                  : tab == 1 && widget.settings.store != null
                  ? DiaryScreen(
                      database: widget.settings.store!.database,
                      selectedDate: diaryDate,
                      onSelectDate: _selectDiaryDate,
                      currency: widget.settings.settings.currency ?? 'PLN',
                      receipts: ReceiptAttachmentStore(widget.settings.store!),
                      onOpenReceipt: _openReceipt,
                      recoveredReceipt: _recoveredReceipt,
                      onRecoveredConsumed: () =>
                          setState(() => _recoveredReceipt = null),
                    )
                  : tab == 2 && widget.settings.store != null
                  ? WeeksScreen(
                      month: YearMonth(month.year, month.month),
                      database: widget.settings.store!.database,
                      currency: widget.settings.settings.currency ?? 'PLN',
                    )
                  : tab == 3 && widget.settings.store != null
                  ? BalanceScreen(
                      month: YearMonth(month.year, month.month),
                      database: widget.settings.store!.database,
                      currency: widget.settings.settings.currency ?? 'PLN',
                      yearMode: balanceYearMode,
                      onYearMode: (value) =>
                          setState(() => balanceYearMode = value),
                      onSelectMonth: (value) => setState(
                        () => month = DateTime(value.year, value.month),
                      ),
                    )
                  : const _FeaturePreview(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomTabs(
        labels: labels,
        current: tab,
        onSelect: _selectTab,
      ),
    );
  }
}

class _ReceiptPreview extends StatefulWidget {
  const _ReceiptPreview({required this.image});

  final File image;

  @override
  State<_ReceiptPreview> createState() => _ReceiptPreviewState();
}

class _ReceiptPreviewState extends State<_ReceiptPreview> {
  int turns = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Paragon / Receipt'),
      actions: [
        IconButton(
          tooltip: 'Obróć / Rotate',
          onPressed: () => setState(() => turns = (turns + 1) % 4),
          icon: const Icon(Icons.rotate_right),
        ),
      ],
    ),
    body: Center(
      child: InteractiveViewer(
        minScale: .5,
        maxScale: 5,
        child: RotatedBox(
          quarterTurns: turns,
          child: Image.file(
            widget.image,
            errorBuilder: (context, error, stack) => const Text(
              'Nie udało się odczytać zdjęcia. / Could not read image.',
            ),
          ),
        ),
      ),
    ),
  );
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.month,
    this.periodLabel,
    this.onPrevious,
    this.onNext,
    required this.onOpenProfile,
  });

  final String title;
  final DateTime? month;
  final String? periodLabel;
  final VoidCallback? onPrevious, onNext;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(kakeboSpacing, 6, kakeboSpacing, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.brandName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 9),
                          child: Text(
                            l10n.japaneseName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key('open_profile'),
                onPressed: onOpenProfile,
                tooltip: l10n.profile,
                visualDensity: VisualDensity.compact,
                icon: const HeroIcon('cog_6_tooth', size: 21),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (month != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  onPressed: onPrevious,
                  tooltip: l10n.previousMonth,
                  visualDensity: VisualDensity.compact,
                  icon: const HeroIcon('chevron_left', size: 18),
                ),
                Expanded(
                  child: Text(
                    periodLabel ??
                        formatMonth(month!, Localizations.localeOf(context)),
                    key: const Key('selected_month'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: onNext,
                  tooltip: l10n.nextMonth,
                  visualDensity: VisualDensity.compact,
                  icon: const HeroIcon('chevron_right', size: 18),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomTabs extends StatelessWidget {
  const _BottomTabs({
    required this.labels,
    required this.current,
    required this.onSelect,
  });

  final List<String> labels;
  final int current;
  final ValueChanged<int> onSelect;

  static const _icons = [
    'calendar_days',
    'list_bullet',
    'chart_bar',
    'chart_pie',
    'user',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final height = (64 + (scale - 1).clamp(0, 1) * 18).toDouble();
    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = index == current;
              final color = selected ? scheme.primary : scheme.onSurfaceVariant;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: labels[index],
                  child: InkWell(
                    key: Key('tab_$index'),
                    onTap: () => onSelect(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected
                                ? scheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 3,
                            ),
                            child: HeroIcon(
                              _icons[index],
                              size: 22,
                              color: selected
                                  ? scheme.onPrimaryContainer
                                  : color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              labels[index],
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: color,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _FeaturePreview extends StatelessWidget {
  const _FeaturePreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.developmentVersion,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.developmentMessage, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = settings.settings;
    Future<void> update(Future<void> Function() operation) async {
      try {
        await operation();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.settingsSaveError)));
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(kakeboSpacing),
      children: [
        _SettingChoice(
          label: l10n.language,
          value: data.language ?? 'pl',
          options: {'pl': l10n.polish, 'en': l10n.english},
          onChanged: settings.saving
              ? null
              : (value) => update(() => settings.update(language: value)),
        ),
        _SettingChoice(
          label: l10n.theme,
          value: data.theme ?? 'SYSTEM',
          options: {
            'SYSTEM': l10n.system,
            'LIGHT': l10n.light,
            'DARK': l10n.dark,
          },
          onChanged: settings.saving
              ? null
              : (value) => update(() => settings.update(theme: value)),
        ),
        _SettingChoice(
          label: l10n.currency,
          value: data.currency ?? 'PLN',
          options: const {
            'PLN': 'PLN',
            'EUR': 'EUR',
            'USD': 'USD',
            'GBP': 'GBP',
          },
          onChanged: settings.saving
              ? null
              : (value) => update(() => settings.update(currency: value)),
        ),
        const SizedBox(height: 12),
        Text(l10n.previewAmount, style: Theme.of(context).textTheme.labelLarge),
        Text(
          formatMoney(
            123456,
            currencyCode: data.currency ?? 'PLN',
            locale: Localizations.localeOf(context),
          ),
          key: const Key('formatted_amount'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.bookName,
            border: const OutlineInputBorder(),
          ),
          initialValue: data.bookName,
          onFieldSubmitted: (value) =>
              update(() => settings.update(bookName: value)),
        ),
      ],
    );
  }
}

class _SettingChoice extends StatelessWidget {
  const _SettingChoice({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label, value;
  final Map<String, String> options;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final entry in options.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged == null
          ? null
          : (value) {
              if (value != null) onChanged!(value);
            },
    ),
  );
}

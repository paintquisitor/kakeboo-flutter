import 'models.dart';

List<Entry> expensesInMonth(
  MonthlyPlanWithItems plan,
  Iterable<Entry> entries,
) {
  final month = plan.plan.month;
  return entries
      .where(
        (e) =>
            e.type == EntryType.expense &&
            e.dateEpochDay >= month.firstDay.epochDay &&
            e.dateEpochDay <= month.lastDay.epochDay,
      )
      .toList();
}

enum MatchReviewReason { ambiguousTitle, amountOnly, alreadyLinked }

final class FixedExpenseReview {
  FixedExpenseReview(this.entry, Iterable<int> candidateItemIds, this.reason)
    : candidateItemIds = List.unmodifiable(candidateItemIds);
  final Entry entry;
  final List<int> candidateItemIds;
  final MatchReviewReason reason;
}

final class ReconciledExpenses {
  ReconciledExpenses(
    Iterable<Entry> all,
    Map<Entry, int> assignments,
    Iterable<FixedExpenseReview> reviews,
  ) : all = List.unmodifiable(all),
      assignments = Map.unmodifiable(assignments),
      reviews = List.unmodifiable(reviews);
  final List<Entry> all;

  /// Entry identity (not amount or list position) distinguishes identical payments.
  final Map<Entry, int> assignments;
  final List<FixedExpenseReview> reviews;
  List<Entry> get variable =>
      all.where((e) => !assignments.containsKey(e)).toList();
  Map<int, int> get fixedActualById {
    final totals = <int, int>{};
    for (final e in assignments.entries) {
      totals[e.value] = (totals[e.value] ?? 0) + e.key.amountGrosz;
    }
    return Map.unmodifiable(totals);
  }
}

ReconciledExpenses reconcileExpenses(
  MonthlyPlanWithItems plan,
  Iterable<Entry> entries,
) {
  final expenses = expensesInMonth(plan, entries);
  final fixed = plan.items
      // id=0 is an unsaved draft, not a stable payment target.
      .where((i) => i.id > 0 && i.type == EntryType.expense && i.isDueIn())
      .toList();
  final fixedIds = fixed.map((i) => i.id).toSet();
  final assignments = <Entry, int>{
    for (final e in expenses)
      if (e.plannedItemId != null && fixedIds.contains(e.plannedItemId))
        e: e.plannedItemId!,
  };
  final linkedIds = assignments.values.toSet();
  final candidates = expenses
      .where(
        (e) =>
            e.plannedItemId == null &&
            e.subcategory == null &&
            e.customSubcategoryId == null &&
            e.receiptName == null,
      )
      .toList();
  final titleMatches = <Entry, List<PlannedItem>>{
    for (final e in candidates)
      e: fixed.where((i) => _matchesTitle(e.note, i.title)).toList(),
  };
  final reviews = <FixedExpenseReview>[];
  for (final entry in candidates) {
    final matches = titleMatches[entry]!;
    if (matches.isNotEmpty) {
      final item = matches.first;
      final competingEntries = titleMatches.values
          .where((items) => items.contains(item))
          .length;
      if (matches.length == 1 &&
          competingEntries == 1 &&
          !linkedIds.contains(item.id)) {
        assignments[entry] = item.id;
      } else {
        reviews.add(
          FixedExpenseReview(
            entry,
            matches.map((i) => i.id),
            matches.length == 1 && linkedIds.contains(item.id)
                ? MatchReviewReason.alreadyLinked
                : MatchReviewReason.ambiguousTitle,
          ),
        );
      }
    } else {
      final sameAmount = fixed.where((i) => i.amountGrosz == entry.amountGrosz);
      if (sameAmount.isNotEmpty) {
        // A suggestion only: a matching amount never removes a diary expense.
        reviews.add(
          FixedExpenseReview(
            entry,
            sameAmount.map((i) => i.id),
            MatchReviewReason.amountOnly,
          ),
        );
      }
    }
  }
  return ReconciledExpenses(expenses, assignments, reviews);
}

Set<String> _words(String value) {
  const accented = 'ąćęłńóśźżáàâäãåçéèêëíìîïñôöõúùûüýÿ';
  const plain = 'acelnoszzaaaaaaceeeeiiiinooouuuuyy';
  var normalized = value.toLowerCase();
  for (var i = 0; i < accented.length; i++) {
    normalized = normalized.replaceAll(accented[i], plain[i]);
  }
  normalized = normalized.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  return normalized
      .split(RegExp('[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toSet();
}

bool _matchesTitle(String note, String title) {
  final titleWords = _words(title).where((word) => word.length >= 3);
  final noteWords = _words(note);
  return titleWords.isNotEmpty && titleWords.every(noteWords.contains);
}

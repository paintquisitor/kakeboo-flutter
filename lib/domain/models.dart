import '../core/time/calendar_date.dart';
import 'expense_category.dart';

enum EntryType {
  income('INCOME'),
  expense('EXPENSE');

  const EntryType(this.storageKey);
  final String storageKey;
}

enum PlanRecurrence {
  monthly('MONTHLY', 1),
  quarterly('QUARTERLY', 3),
  yearly('YEARLY', 12);

  const PlanRecurrence(this.storageKey, this.months);
  final String storageKey;
  final int months;
}

final class Entry {
  Entry({
    this.id = 0,
    required this.amountGrosz,
    required this.type,
    required this.dateEpochDay,
    this.note = '',
    this.subcategory,
    this.plannedItemId,
    this.receiptName,
    this.customSubcategoryId,
  }) {
    CalendarDate.fromEpochDay(dateEpochDay);
    if (amountGrosz <= 0 ||
        (subcategory != null && customSubcategoryId != null) ||
        (type == EntryType.income &&
            (subcategory != null ||
                plannedItemId != null ||
                receiptName != null ||
                customSubcategoryId != null))) {
      throw ArgumentError('Invalid entry');
    }
  }
  final int id;
  final int amountGrosz;
  final EntryType type;
  final int dateEpochDay;
  final String note;
  final ExpenseSubcategory? subcategory;
  final int? plannedItemId;
  final String? receiptName;
  final int? customSubcategoryId;
}

final class MonthlyPlan {
  MonthlyPlan({
    required this.month,
    this.savingsGrosz = 0,
    this.resolutions = '',
  }) {
    if (savingsGrosz < 0) throw ArgumentError('Negative savings goal');
  }
  final YearMonth month;
  final int savingsGrosz;
  final String resolutions;
}

final class PlannedItem {
  PlannedItem({
    this.id = 0,
    required this.month,
    required this.type,
    required this.title,
    required this.amountGrosz,
    required this.dateEpochDay,
    this.recurrence = PlanRecurrence.monthly,
    YearMonth? recurrenceAnchorMonth,
    this.icon = '',
  }) : recurrenceAnchorMonth = recurrenceAnchorMonth ?? month {
    if (title.trim().isEmpty ||
        amountGrosz <= 0 ||
        CalendarDate.fromEpochDay(dateEpochDay).yearMonth != month) {
      throw ArgumentError('Invalid planned item');
    }
  }
  final int id;
  final YearMonth month;
  final EntryType type;
  final String title;
  final int amountGrosz;
  final int dateEpochDay;
  final PlanRecurrence recurrence;
  final YearMonth recurrenceAnchorMonth;
  // Keep the persisted icon identifier, including unknown future identifiers.
  final String icon;

  bool isDueIn([YearMonth? target]) {
    final elapsed = recurrenceAnchorMonth.monthsUntil(target ?? month);
    return elapsed >= 0 && elapsed % recurrence.months == 0;
  }

  YearMonth nextDueMonth([YearMonth? from]) {
    final start = from ?? month;
    final elapsed = recurrenceAnchorMonth.monthsUntil(start);
    if (elapsed <= 0) return recurrenceAnchorMonth;
    return start.plusMonths(
      (recurrence.months - elapsed % recurrence.months) % recurrence.months,
    );
  }

  PlannedItem carriedTo(YearMonth target) {
    final day = CalendarDate.fromEpochDay(dateEpochDay).day;
    return PlannedItem(
      month: target,
      type: type,
      title: title,
      amountGrosz: amountGrosz,
      dateEpochDay: target
          .atDay(day > target.lengthOfMonth ? target.lengthOfMonth : day)
          .epochDay,
      recurrence: recurrence,
      recurrenceAnchorMonth: recurrenceAnchorMonth,
      icon: icon,
    );
  }
}

final class MonthlyPlanWithItems {
  MonthlyPlanWithItems(this.plan, Iterable<PlannedItem> items)
    : items = List.unmodifiable(items) {
    if (this.items.any((item) => item.month != plan.month)) {
      throw ArgumentError('Item belongs to another month');
    }
    final savedIds = this.items
        .where((item) => item.id != 0)
        .map((item) => item.id);
    if (savedIds.toSet().length != savedIds.length) {
      throw ArgumentError('Duplicate planned item ID');
    }
  }
  factory MonthlyPlanWithItems.empty(YearMonth month) =>
      MonthlyPlanWithItems(MonthlyPlan(month: month), const []);
  final MonthlyPlan plan;
  final List<PlannedItem> items;
}

final class CustomCategory {
  const CustomCategory({
    required this.id,
    required this.name,
    required this.nameKey,
    this.icon = 'WALLET',
  });
  final int id;
  final String name;
  final String nameKey;
  final String icon;
}

final class CustomSubcategory {
  const CustomSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameKey,
  });
  final int id;
  final int categoryId;
  final String name;
  final String nameKey;
}

final class CustomCategoryWithSubcategories {
  CustomCategoryWithSubcategories(
    this.category,
    Iterable<CustomSubcategory> subcategories,
  ) : subcategories = List.unmodifiable(subcategories) {
    if (this.subcategories.any((s) => s.categoryId != category.id)) {
      throw ArgumentError('Subcategory belongs to another category');
    }
  }
  final CustomCategory category;
  final List<CustomSubcategory> subcategories;
}

final class MonthlyReflection {
  const MonthlyReflection({
    required this.month,
    this.successes = '',
    this.improvements = '',
    this.nextMonth = '',
  });
  final YearMonth month;
  final String successes;
  final String improvements;
  final String nextMonth;
}

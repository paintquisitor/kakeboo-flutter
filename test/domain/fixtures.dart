import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/domain/expense_category.dart';
import 'package:kakebo/domain/models.dart';

final class TestDateSource implements DateSource {
  TestDateSource(String date) : value = CalendarDate.parse(date);
  CalendarDate value;
  @override
  CalendarDate today() => value;
}

YearMonth ym(String month) => YearMonth.parse(month);
PlannedItem item({
  int id = 2,
  String month = '2026-09',
  EntryType type = EntryType.expense,
  String title = 'Czynsz',
  int amount = 100000,
  int day = 1,
  PlanRecurrence recurrence = PlanRecurrence.monthly,
  String? anchor,
  String icon = '',
}) => PlannedItem(
  id: id,
  month: ym(month),
  type: type,
  title: title,
  amountGrosz: amount,
  dateEpochDay: ym(month).atDay(day).epochDay,
  recurrence: recurrence,
  recurrenceAnchorMonth: anchor == null ? null : ym(anchor),
  icon: icon,
);

MonthlyPlanWithItems plan({
  String month = '2026-09',
  int income = 300000,
  int fixed = 100000,
  int savings = 20000,
  String fixedTitle = 'Czynsz',
}) => MonthlyPlanWithItems(
  MonthlyPlan(
    month: ym(month),
    savingsGrosz: savings,
    resolutions: 'Plan testowy',
  ),
  [
    if (income > 0)
      item(
        id: 1,
        month: month,
        type: EntryType.income,
        title: 'Pensja',
        amount: income,
      ),
    if (fixed > 0) item(month: month, title: fixedTitle, amount: fixed),
  ],
);

Entry expense(
  int amount, {
  int id = 0,
  int day = 1,
  String month = '2026-09',
  int? bill,
  ExpenseSubcategory? subcategory = ExpenseSubcategory.food,
  String note = '',
  String? receipt,
  int? customId,
}) => Entry(
  id: id,
  amountGrosz: amount,
  type: EntryType.expense,
  dateEpochDay: ym(month).atDay(day).epochDay,
  plannedItemId: bill,
  subcategory: subcategory,
  note: note,
  receiptName: receipt,
  customSubcategoryId: customId,
);

import '../core/time/calendar_date.dart';
import 'models.dart';

/// F04 must implement createIfAbsent as ONE database transaction, allocating
/// fresh item IDs and leaving an already existing month entirely unchanged.
abstract interface class MonthlyPlanStore {
  Future<MonthlyPlanWithItems?> findMonth(YearMonth month);
  Future<MonthlyPlanWithItems?> findPreviousMonth(YearMonth month);
  Future<bool> createIfAbsent(MonthlyPlanWithItems draft);
}

final class PlanLifecycle {
  PlanLifecycle(this.store, this.dates);
  final MonthlyPlanStore store;
  final DateSource dates;

  /// Navigation is read-only, even for gaps in history or stored future plans.
  Future<MonthlyPlanWithItems> readMonth(YearMonth month) async =>
      await store.findMonth(month) ?? MonthlyPlanWithItems.empty(month);

  /// Call on startup, resume, and at the next local day boundary while active.
  /// No selected-month argument: browsing cannot create past or future plans.
  Future<bool> activateCurrentMonth() async {
    final target = dates.today().yearMonth;
    if (await store.findMonth(target) != null) return false;
    final previous = await store.findPreviousMonth(target);
    if (previous == null || previous.plan.month.compareTo(target) >= 0) {
      return false;
    }
    final draft = MonthlyPlanWithItems(
      MonthlyPlan(
        month: target,
        savingsGrosz: previous.plan.savingsGrosz,
        resolutions: previous.plan.resolutions,
      ),
      // Retain non-due templates too, so quarterly/yearly items recur later.
      previous.items.map((item) => item.carriedTo(target)),
    );
    // A suspended lookup crossing midnight must not create a stale month.
    if (dates.today().yearMonth != target) return activateCurrentMonth();
    return store.createIfAbsent(draft);
  }
}

import 'expense_category.dart';
import 'models.dart';

final class ExpenseCatalog {
  ExpenseCatalog([Iterable<CustomCategoryWithSubcategories> custom = const []])
    : custom = List.unmodifiable(custom) {
    subcategories = Map.unmodifiable({
      for (final c in this.custom)
        for (final s in c.subcategories) s.id: s,
    });
  }
  final List<CustomCategoryWithSubcategories> custom;
  late final Map<int, CustomSubcategory> subcategories;
  List<CategoryKey> get keys => [
    ...ExpenseCategory.values.map((c) => c.key),
    ...custom.map((c) => CategoryKey.custom(c.category.id)),
  ];
  CategoryKey? categoryOf(Entry entry) {
    if (entry.subcategory != null) return entry.subcategory!.category.key;
    final custom = subcategories[entry.customSubcategoryId];
    return custom == null ? null : CategoryKey.custom(custom.categoryId);
  }

  Map<CategoryKey?, int> totals(Iterable<Entry> entries) {
    final totals = <CategoryKey?, int>{};
    for (final entry in entries.where((e) => e.type == EntryType.expense)) {
      final key = categoryOf(entry);
      totals[key] = (totals[key] ?? 0) + entry.amountGrosz;
    }
    return Map.unmodifiable(totals);
  }
}

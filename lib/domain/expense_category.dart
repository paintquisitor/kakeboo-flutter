enum ExpenseCategory {
  needs('NEEDS'),
  optional('OPTIONAL'),
  hobby('HOBBY'),
  extra('EXTRA');

  const ExpenseCategory(this.storageKey);
  final String storageKey;
  CategoryKey get key => CategoryKey.builtIn(this);
  List<ExpenseSubcategory> get subcategories =>
      ExpenseSubcategory.values.where((s) => s.category == this).toList();
}

enum ExpenseSubcategory {
  food('FOOD', ExpenseCategory.needs, 'CART'),
  transport('TRANSPORT', ExpenseCategory.needs, 'TRANSPORT'),
  healthMedicine('HEALTH_MEDICINE', ExpenseCategory.needs, 'MEDICINE'),
  hygiene('HYGIENE', ExpenseCategory.needs, 'SPARKLES'),
  children('CHILDREN', ExpenseCategory.needs, 'CHILDREN'),
  pets('PETS', ExpenseCategory.needs, 'ANIMALS'),
  basicClothing('BASIC_CLOTHING', ExpenseCategory.needs, 'BAG'),
  dining('DINING', ExpenseCategory.optional, 'CAKE'),
  clothing('CLOTHING', ExpenseCategory.optional, 'BAG'),
  cosmetics('COSMETICS', ExpenseCategory.optional, 'HAIRCUT'),
  decoration('DECORATION', ExpenseCategory.optional, 'HOME'),
  gadgets('GADGETS', ExpenseCategory.optional, 'COMPUTER'),
  travel('TRAVEL', ExpenseCategory.optional, 'TRAVEL'),
  books('BOOKS', ExpenseCategory.hobby, 'BOOK'),
  performances('PERFORMANCES', ExpenseCategory.hobby, 'TICKET'),
  events('EVENTS', ExpenseCategory.hobby, 'PLACES'),
  hobbyActivities('HOBBY_ACTIVITIES', ExpenseCategory.hobby, 'ART'),
  games('GAMES', ExpenseCategory.hobby, 'GAMES'),
  sport('SPORT', ExpenseCategory.hobby, 'SPORT'),
  media('MEDIA', ExpenseCategory.hobby, 'FILM'),
  repairs('REPAIRS', ExpenseCategory.extra, 'REPAIRS'),
  emergencyHealth('EMERGENCY_HEALTH', ExpenseCategory.extra, 'HEALTH'),
  replacement('REPLACEMENT', ExpenseCategory.extra, 'PACKAGES'),
  extraOther('EXTRA_OTHER', ExpenseCategory.extra, 'WALLET');

  const ExpenseSubcategory(this.storageKey, this.category, this.icon);
  final String storageKey;
  final ExpenseCategory category;
  final String icon;
  static ExpenseSubcategory fromStorageKey(String key) => values.firstWhere(
    (value) => value.storageKey == key,
    orElse: () => throw FormatException('Unknown subcategory', key),
  );
}

/// Null keys in reports mean legacy uncategorized expenses ("Wydatki z karty").
final class CategoryKey {
  const CategoryKey.builtIn(ExpenseCategory category)
    : builtIn = category,
      customId = null;
  const CategoryKey.custom(int id) : customId = id, builtIn = null;
  final ExpenseCategory? builtIn;
  final int? customId;
  @override
  bool operator ==(Object other) =>
      other is CategoryKey &&
      other.builtIn == builtIn &&
      other.customId == customId;
  @override
  int get hashCode => Object.hash(builtIn, customId);
}

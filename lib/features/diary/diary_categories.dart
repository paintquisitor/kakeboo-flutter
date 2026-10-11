import 'package:flutter/material.dart';

import '../../app/category_icons.dart';
import '../../domain/expense_category.dart';
import '../../domain/expense_catalog.dart';

String diaryText(BuildContext context, String pl, String en) =>
    Localizations.localeOf(context).languageCode == 'en' ? en : pl;

String categoryLabel(
  BuildContext context,
  CategoryKey? key,
  ExpenseCatalog catalog,
) {
  if (key == null) {
    return diaryText(context, 'Wydatki z karty', 'Card expenses');
  }
  if (key.customId != null) {
    for (final item in catalog.custom) {
      if (item.category.id == key.customId) return item.category.name;
    }
    return diaryText(context, 'Wydatki z karty', 'Card expenses');
  }
  return switch (key.builtIn!) {
    ExpenseCategory.needs => diaryText(
      context,
      'Pierwszej potrzeby',
      'Essentials',
    ),
    ExpenseCategory.optional => diaryText(context, 'Opcjonalne', 'Optional'),
    ExpenseCategory.hobby => diaryText(
      context,
      'Kultura i czas wolny',
      'Culture and leisure',
    ),
    ExpenseCategory.extra => diaryText(
      context,
      'Ekstra i nieprzewidziane',
      'Extra and unexpected',
    ),
  };
}

String subcategoryLabel(BuildContext context, ExpenseSubcategory subcategory) {
  final labels = <ExpenseSubcategory, (String, String)>{
    ExpenseSubcategory.food: ('Żywność', 'Food'),
    ExpenseSubcategory.transport: ('Transport', 'Transport'),
    ExpenseSubcategory.healthMedicine: (
      'Zdrowie i leki',
      'Health and medicine',
    ),
    ExpenseSubcategory.hygiene: ('Higiena i czystość', 'Hygiene and cleaning'),
    ExpenseSubcategory.children: ('Dzieci i opieka', 'Children and childcare'),
    ExpenseSubcategory.pets: ('Zwierzęta', 'Pets'),
    ExpenseSubcategory.basicClothing: ('Podstawowa odzież', 'Basic clothing'),
    ExpenseSubcategory.dining: (
      'Jedzenie na mieście i dostawy',
      'Dining out and delivery',
    ),
    ExpenseSubcategory.clothing: ('Moda i dodatki', 'Fashion and accessories'),
    ExpenseSubcategory.cosmetics: (
      'Uroda i pielęgnacja',
      'Beauty and personal care',
    ),
    ExpenseSubcategory.decoration: (
      'Dekoracje i dodatkowe wyposażenie domu',
      'Decor and additional home furnishings',
    ),
    ExpenseSubcategory.gadgets: ('Gadżety', 'Gadgets'),
    ExpenseSubcategory.travel: ('Podróże wypoczynkowe', 'Leisure travel'),
    ExpenseSubcategory.books: ('Książki i prasa', 'Books and press'),
    ExpenseSubcategory.performances: (
      'Kino, teatr i koncerty',
      'Cinema, theatre, and concerts',
    ),
    ExpenseSubcategory.events: ('Muzea i wydarzenia', 'Museums and events'),
    ExpenseSubcategory.hobbyActivities: (
      'Hobby i zajęcia',
      'Hobbies and activities',
    ),
    ExpenseSubcategory.games: ('Gry', 'Games'),
    ExpenseSubcategory.sport: ('Sport i rekreacja', 'Sports and recreation'),
    ExpenseSubcategory.media: ('Filmy i muzyka', 'Movies and music'),
    ExpenseSubcategory.repairs: ('Naprawy i awarie', 'Repairs and breakdowns'),
    ExpenseSubcategory.emergencyHealth: (
      'Nagłe wydatki zdrowotne',
      'Unexpected medical expenses',
    ),
    ExpenseSubcategory.replacement: (
      'Wymiana zepsutego sprzętu',
      'Replacing broken equipment',
    ),
    ExpenseSubcategory.extraOther: (
      'Nieplanowane opłaty i inne niespodziewane koszty',
      'Unplanned fees and other unexpected costs',
    ),
  };
  final label = labels[subcategory]!;
  return diaryText(context, label.$1, label.$2);
}

Color categoryColor(BuildContext context, CategoryKey? key) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final palette =
      key?.builtIn ??
      (key?.customId == null
          ? null
          : ExpenseCategory.values[key!.customId! %
                ExpenseCategory.values.length]);
  return switch (palette) {
    ExpenseCategory.needs =>
      dark ? const Color(0xFF98D8BE) : const Color(0xFF247D68),
    ExpenseCategory.optional =>
      dark ? const Color(0xFFD3B27C) : const Color(0xFF9A713B),
    ExpenseCategory.hobby =>
      dark ? const Color(0xFFD5B9E7) : const Color(0xFF7C5792),
    ExpenseCategory.extra =>
      dark ? const Color(0xFFA9CAE8) : const Color(0xFF4779A4),
    null => dark ? const Color(0xFF72C7F4) : const Color(0xFF287FB8),
  };
}

String categoryIconId(CategoryKey? key, ExpenseCatalog catalog) {
  if (key?.customId != null) {
    for (final item in catalog.custom) {
      if (item.category.id == key!.customId) return item.category.icon;
    }
  }
  return switch (key?.builtIn) {
    ExpenseCategory.needs => 'CART',
    ExpenseCategory.optional => 'BAG',
    ExpenseCategory.hobby => 'MUSIC',
    ExpenseCategory.extra => 'SPARKLES',
    null => 'CARD',
  };
}

String categoryIconAsset(CategoryKey? key, ExpenseCatalog catalog) =>
    categoryIcon(categoryIconId(key, catalog)).asset;

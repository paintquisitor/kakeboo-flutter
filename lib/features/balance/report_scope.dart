import 'package:flutter/material.dart';

import '../../data/kakebo_database.dart';
import '../../domain/expense_catalog.dart';
import '../../domain/models.dart';

class ReportData {
  const ReportData(this.plans, this.entries, this.catalog);
  final List<MonthlyPlanWithItems> plans;
  final List<Entry> entries;
  final ExpenseCatalog catalog;
}

/// Reads existing data only. Merely opening reports cannot carry a plan forward.
class ReportScope extends StatelessWidget {
  const ReportScope({
    super.key,
    required this.database,
    required this.year,
    required this.builder,
  });
  final KakeboDatabase database;
  final int year;
  final Widget Function(BuildContext, ReportData) builder;

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: database.watchYear(year),
    builder: (context, plans) => StreamBuilder(
      stream: database.watchEntries(),
      builder: (context, entries) => StreamBuilder(
        stream: database.watchCategories(),
        builder: (context, categories) => StreamBuilder(
          stream: database.watchSubcategories(),
          builder: (context, subcategories) {
            if (!plans.hasData ||
                !entries.hasData ||
                !categories.hasData ||
                !subcategories.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final custom = categories.data!
                .map(
                  (category) => CustomCategoryWithSubcategories(
                    CustomCategory(
                      id: category.id,
                      name: category.name,
                      nameKey: category.nameKey,
                      icon: category.icon,
                    ),
                    subcategories.data!
                        .where((item) => item.categoryId == category.id)
                        .map(
                          (item) => CustomSubcategory(
                            id: item.id,
                            categoryId: item.categoryId,
                            name: item.name,
                            nameKey: item.nameKey,
                          ),
                        ),
                  ),
                )
                .toList();
            return builder(
              context,
              ReportData(plans.data!, entries.data!, ExpenseCatalog(custom)),
            );
          },
        ),
      ),
    ),
  );
}

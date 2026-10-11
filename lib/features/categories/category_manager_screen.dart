import 'package:flutter/material.dart';

import '../../app/category_icons.dart';
import '../../app/hero_icon.dart';
import '../../data/kakebo_database.dart';
import '../../domain/models.dart' as domain;
import '../plan/plan_screen.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key, required this.database});
  final KakeboDatabase database;

  Future<void> _edit(
    BuildContext context, {
    CustomCategoryRow? category,
    CustomSubcategoryRow? subcategory,
    int? parentId,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CategoryEditor(
        database: database,
        category: category,
        subcategory: subcategory,
        parentId: parentId,
      ),
    );
  }

  Future<void> _remove(
    BuildContext context, {
    CustomCategoryRow? category,
    CustomSubcategoryRow? subcategory,
  }) async {
    final name = category?.name ?? subcategory!.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planText(context, 'Usunąć „$name”?', 'Delete “$name”?')),
        content: Text(
          planText(
            context,
            'Pozycji powiązanej z zapisanym wydatkiem nie można usunąć.',
            'An item linked to a saved expense cannot be deleted.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(planText(context, 'Anuluj', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(planText(context, 'Usuń', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      if (category != null) {
        await database.deleteCategory(category.id);
      } else {
        await database.deleteSubcategory(subcategory!.id);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              planText(
                context,
                'Nie można usunąć: istnieją powiązane wydatki.',
                'Cannot delete: linked expenses exist.',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        planText(context, 'Kategorie wydatków', 'Expense categories'),
      ),
    ),
    body: StreamBuilder<List<CustomCategoryRow>>(
      stream: database.watchCategories(),
      builder: (context, categoriesSnapshot) =>
          StreamBuilder<List<CustomSubcategoryRow>>(
            stream: database.watchSubcategories(),
            builder: (context, subcategoriesSnapshot) {
              if (categoriesSnapshot.hasError ||
                  subcategoriesSnapshot.hasError) {
                return Center(
                  child: Text(
                    planText(
                      context,
                      'Nie udało się wczytać kategorii.',
                      'Could not load categories.',
                    ),
                  ),
                );
              }
              if (!categoriesSnapshot.hasData ||
                  !subcategoriesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = categoriesSnapshot.data!.toList()
                ..sort((a, b) => a.name.compareTo(b.name));
              final children = subcategoriesSnapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    planText(
                      context,
                      'Własne kategorie i podkategorie',
                      'Custom categories and subcategories',
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    planText(
                      context,
                      'Domyślne cztery grupy są zawsze dostępne przy dodawaniu wydatku.',
                      'The four built-in groups are always available when adding expenses.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (categories.isEmpty)
                    Text(
                      planText(
                        context,
                        'Nie masz jeszcze własnych kategorii.',
                        'No custom categories yet.',
                      ),
                    ),
                  for (final category in categories)
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            key: Key('category_${category.id}'),
                            leading: StoredCategoryIcon(
                              category.icon,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _edit(context, category: category),
                                  tooltip: planText(context, 'Edytuj', 'Edit'),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _remove(context, category: category),
                                  tooltip: planText(context, 'Usuń', 'Delete'),
                                  icon: const HeroIcon('trash', size: 20),
                                ),
                              ],
                            ),
                          ),
                          for (final sub in children.where(
                            (s) => s.categoryId == category.id,
                          ))
                            ListTile(
                              key: Key('subcategory_${sub.id}'),
                              contentPadding: const EdgeInsets.only(
                                left: 56,
                                right: 8,
                              ),
                              leading: StoredCategoryIcon(
                                category.icon,
                                size: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              title: Text(sub.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _edit(context, subcategory: sub),
                                    tooltip: planText(
                                      context,
                                      'Edytuj',
                                      'Edit',
                                    ),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 19,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _remove(context, subcategory: sub),
                                    tooltip: planText(
                                      context,
                                      'Usuń',
                                      'Delete',
                                    ),
                                    icon: const HeroIcon('trash', size: 19),
                                  ),
                                ],
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _edit(context, parentId: category.id),
                              icon: const HeroIcon('plus', size: 18),
                              label: Text(
                                planText(
                                  context,
                                  'Dodaj podkategorię',
                                  'Add subcategory',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _edit(context),
                    icon: const HeroIcon('plus', size: 19),
                    label: Text(
                      planText(context, 'Dodaj kategorię', 'Add category'),
                    ),
                  ),
                ],
              );
            },
          ),
    ),
  );
}

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({
    required this.database,
    this.category,
    this.subcategory,
    this.parentId,
  });
  final KakeboDatabase database;
  final CustomCategoryRow? category;
  final CustomSubcategoryRow? subcategory;
  final int? parentId;
  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final name = TextEditingController(
    text: widget.category?.name ?? widget.subcategory?.name ?? '',
  );
  late String icon = widget.category?.icon ?? 'WALLET';
  bool saving = false;
  String? error;
  bool get subcategory => widget.subcategory != null || widget.parentId != null;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final clean = name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty || clean.length > 60) {
      setState(
        () => error = planText(
          context,
          'Nazwa musi mieć od 1 do 60 znaków.',
          'The name must have 1 to 60 characters.',
        ),
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      if (subcategory) {
        await widget.database.saveSubcategory(
          domain.CustomSubcategory(
            id: widget.subcategory?.id ?? 0,
            categoryId: widget.subcategory?.categoryId ?? widget.parentId!,
            name: clean,
            nameKey: clean.toLowerCase(),
          ),
        );
      } else {
        await widget.database.saveCategory(
          domain.CustomCategory(
            id: widget.category?.id ?? 0,
            name: clean,
            nameKey: clean.toLowerCase(),
            icon: icon,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = planText(
            context,
            'Nie udało się zapisać. Sprawdź, czy nazwa już istnieje.',
            'Could not save. Check whether the name already exists.',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      subcategory
          ? planText(context, 'Podkategoria', 'Subcategory')
          : planText(context, 'Kategoria', 'Category'),
    ),
    content: SizedBox(
      width: 350,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: planText(context, 'Nazwa', 'Name'),
              ),
            ),
            if (!subcategory)
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
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
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

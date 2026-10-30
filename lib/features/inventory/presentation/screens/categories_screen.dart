import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/inventory_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.addCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.categoryName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.btnCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(inventoryRepositoryProvider)
                    .saveCategory(name: name);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              }
            },
            child: Text(l10n.btnSave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(activeCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: Text(l10n.emptyState),
              action: FilledButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.addCategory),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsetsDirectional.all(kSpaceM),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: kSpaceXS),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.folder_outlined,
                      color: AppColors.primary),
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.archive_outlined),
                    tooltip: l10n.btnDelete,
                    onPressed: () async {
                      await ref
                          .read(inventoryRepositoryProvider)
                          .archiveCategory(cat.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

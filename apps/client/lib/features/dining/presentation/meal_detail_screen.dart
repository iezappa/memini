import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tracking/presentation/tracker_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/meal.dart';
import 'meal_form_screen.dart';
import 'meal_providers.dart';

class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final int mealId;

  Future<void> _edit(BuildContext context, Meal meal) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => MealFormScreen(meal: meal)));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Meal meal) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteMeal,
      body: l10n.deleteConfirm(meal.title),
    );
    if (!confirmed) return;

    await ref.read(mealRepositoryProvider).delete(meal.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final meal = ref.watch(mealProvider(mealId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (meal.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, meal.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, meal.value!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: meal.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.restaurant_outlined,
                title: l10n.mealEmptyTitle,
              );
            }
            return TrackerDetailBody(
              title: value.title,
              happenedOn: value.happenedOn,
              rating: value.rating,
              photoPath: value.photoPath,
              placeholderIcon: Icons.restaurant_outlined,
              contextLine: value.location,
              description: value.description,
              review: value.review,
              facts: [
                if (value.dish != null)
                  (label: l10n.fieldDish, value: value.dish!),
                if (value.price != null)
                  (label: l10n.fieldPrice, value: _money(value.price!)),
                if (value.company != null)
                  (label: l10n.fieldCompany, value: value.company!),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Whole amounts read better without a trailing ".0"; cents still show.
  String _money(double value) => value == value.roundToDouble()
      ? '${value.round()}'
      : value.toStringAsFixed(2);
}

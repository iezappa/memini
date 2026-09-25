import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/entry_dialog.dart';
import 'meal_detail_screen.dart';
import 'meal_form_screen.dart';
import 'meal_providers.dart';

class MealListScreen extends ConsumerWidget {
  const MealListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(mealFilterProvider);
    final controller = ref.read(mealFilterProvider.notifier);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen(
      labels: TrackerListLabels(
        title: l10n.domainDining,
        searchHint: l10n.mealSearchHint,
        count: l10n.mealCount,
        addAction: l10n.addMeal,
        emptyTitle: l10n.mealEmptyTitle,
        emptyBody: l10n.mealEmptyBody,
        emptyFiltered: l10n.mealEmptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => trackingSortLabel(l10n, sort),
      ),
      emptyIcon: Icons.restaurant_outlined,
      entries: ref.watch(mealsProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => showEntryDialog(context, const MealFormScreen()),
      entryBuilder: (context, meal) {
        final date = DateFormat.yMMMd(locale).format(meal.happenedOn);
        // The dish, where there is one: a meal's title is the place, so
        // the line under it should say what was eaten there.
        final where = meal.dish;
        return (
          title: meal.title,
          photoOwnerId: meal.id,
          subtitle: where == null ? date : '$where · $date',
          rating: meal.rating,
          icon: Icons.restaurant_outlined,
          posterUrl: null,
          pill: meal.dish == null ? null : _DishPill(dish: meal.dish!),
          onTap: () => showEntryDialog(
            context,
            MealDetailScreen(mealId: meal.id),
            wide: true,
          ),
        );
      },
    );
  }
}

class _DishPill extends StatelessWidget {
  const _DishPill({required this.dish});

  final String dish;

  @override
  Widget build(BuildContext context) {
    return Text(
      dish,
      style: Theme.of(context).textTheme.labelMedium,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

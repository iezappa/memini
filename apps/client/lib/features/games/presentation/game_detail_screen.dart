import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tracking/presentation/tracker_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/game.dart';
import 'game_form_screen.dart';
import 'game_labels.dart';
import 'game_providers.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.gameId});

  final int gameId;

  Future<void> _edit(BuildContext context, Game game) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => GameFormScreen(game: game)));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Game game) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteGame,
      body: l10n.deleteConfirm(game.title),
    );
    if (!confirmed) return;

    await ref.read(gameRepositoryProvider).delete(game.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameProvider(gameId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (game.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, game.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, game.value!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: game.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.sports_esports_outlined,
                title: l10n.gameEmptyTitle,
              );
            }
            return TrackerDetailBody(
              title: value.title,
              happenedOn: value.happenedOn,
              rating: value.rating,
              photoPath: value.photoPath,
              placeholderIcon: Icons.sports_esports_outlined,
              contextLine: value.releaseYear?.toString(),
              badge: Text(gameStatusLabel(l10n, value.status)),
              description: value.description,
              review: value.review,
              facts: [
                if (value.platform != null)
                  (label: l10n.fieldPlatform, value: value.platform!),
                if (value.hoursPlayed != null)
                  (
                    label: l10n.fieldHoursPlayed,
                    value: l10n.hoursValue(_hours(value.hoursPlayed!)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Whole hours read better than "27.0"; halves still matter.
  String _hours(double value) => value == value.roundToDouble()
      ? '${value.round()}'
      : value.toStringAsFixed(1);
}

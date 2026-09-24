import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/tracking/presentation/tracking_labels.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/recommendation.dart';
import '../home_providers.dart';
import '../mood_labels.dart';

/// Something to watch and something to play, drawn at random.
///
/// The only part of the hub that is not about what the owner has already
/// done. It is deliberately small and deliberately forgettable: nothing
/// here is stored, tapping a card does not add anything, and "another"
/// costs one request.
class SuggestionShelf extends ConsumerWidget {
  const SuggestionShelf({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(suggestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MoodPicker(),
        Gap.vSm,
        _Shelf(suggestions: suggestions),
      ],
    );
  }
}

/// "I feel…", and the answer changes what the shelf asks for.
///
/// A dropdown rather than a row of chips. Eight chips is a paragraph of
/// buttons across the hub, and this is one question with one answer — the
/// shape of a single choice is a field, not a wall.
class _MoodPicker extends ConsumerWidget {
  const _MoodPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chosen = ref.watch(chosenMoodProvider);

    return SizedBox(
      // The width of the answer, not of the page: stretched across a
      // desktop window a one-line dropdown reads as a search box.
      width: 320,
      child: DropdownButtonFormField<Mood?>(
        initialValue: chosen,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.homeMoodPrompt,
          prefixIcon: const Icon(Icons.mood_outlined, size: 18),
        ),
        items: [
          DropdownMenuItem(value: null, child: Text(l10n.homeMoodAny)),
          for (final mood in Mood.values)
            DropdownMenuItem(value: mood, child: Text(moodLabel(l10n, mood))),
        ],
        onChanged: (mood) {
          ref.read(chosenMoodProvider.notifier).state = mood;
          // A new question deserves a fresh draw, not the pick that was
          // already on screen.
          ref.read(suggestionRollProvider.notifier).update((roll) => roll + 1);
        },
      ),
    );
  }
}

class _Shelf extends ConsumerWidget {
  const _Shelf({required this.suggestions});

  final AsyncValue<List<Recommendation>> suggestions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return suggestions.when(
      // Nothing while it loads: the hub is readable without this, and a
      // spinner on a page that is otherwise instant reads as a fault.
      loading: () => const SizedBox.shrink(),
      error: (error, _) => _Quiet(
        message: switch (error) {
          RecommendationException(failure: RecommendationFailure.missingKey) =>
            l10n.homeSuggestionsNoKey,
          _ => l10n.homeSuggestionsUnavailable,
        },
      ),
      data: (picks) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeSuggestionsHint(
                    ref
                        .watch(recommendationSourcesProvider)
                        .where((source) => source.isConfigured)
                        .map((source) => source.attribution)
                        .join(' · '),
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.semantics.muted,
                  ),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.casino_outlined, size: 18),
                label: Text(l10n.homeSuggestionsAnother),
                onPressed: () => ref
                    .read(suggestionRollProvider.notifier)
                    .update((roll) => roll + 1),
              ),
            ],
          ),
          Gap.vSm,
          Wrap(
            spacing: Gap.md,
            runSpacing: Gap.md,
            children: [for (final pick in picks) _Card(pick: pick)],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.pick});

  final Recommendation pick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 320,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(Gap.sm + 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: Radii.field,
                child: SizedBox(
                  width: 56,
                  height: 84,
                  child: pick.imageUrl == null
                      ? ColoredBox(color: context.semantics.hairline)
                      : Image.network(
                          pick.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, _) =>
                              ColoredBox(color: context.semantics.hairline),
                        ),
                ),
              ),
              Gap.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pick.title,
                      style: context.text.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        pick.domain.label(l10n),
                        if (pick.year case final year?) '$year',
                      ].join(' · '),
                      style: context.text.bodySmall?.copyWith(
                        color: context.semantics.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A line where the shelf would have been.
///
/// Never an error box: a suggestion nobody asked for failing to arrive is
/// not something to interrupt anyone about.
class _Quiet extends StatelessWidget {
  const _Quiet({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: context.text.bodySmall?.copyWith(color: context.semantics.muted),
  );
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/shared/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/enrichment.dart';

/// Searches [source] and returns the suggestion the owner picked, or null if
/// they backed out.
///
/// Always cancellable and never blocking: a lookup is a convenience, and the
/// form behind it stays fully editable by hand.
Future<EnrichmentSuggestion?> showEnrichmentSheet({
  required BuildContext context,
  required EnrichmentSource source,
  required String initialQuery,
}) {
  return showModalBottomSheet<EnrichmentSuggestion>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        _EnrichmentSheet(source: source, initialQuery: initialQuery),
  );
}

class _EnrichmentSheet extends StatefulWidget {
  const _EnrichmentSheet({required this.source, required this.initialQuery});

  final EnrichmentSource source;
  final String initialQuery;

  @override
  State<_EnrichmentSheet> createState() => _EnrichmentSheetState();
}

class _EnrichmentSheetState extends State<_EnrichmentSheet> {
  late final TextEditingController _query;

  bool _searching = false;
  List<EnrichmentSuggestion>? _results;
  EnrichmentFailure? _failure;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) _search();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final term = _query.text.trim();
    if (term.isEmpty || _searching) return;

    setState(() {
      _searching = true;
      _failure = null;
    });

    try {
      final results = await widget.source.search(term);
      if (mounted) setState(() => _results = results);
    } on EnrichmentException catch (error) {
      if (mounted) setState(() => _failure = error.reason);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  String _failureMessage(AppLocalizations l10n) => switch (_failure!) {
    EnrichmentFailure.offline => l10n.enrichOffline,
    EnrichmentFailure.missingKey => l10n.enrichMissingKey,
    EnrichmentFailure.failed => l10n.enrichFailed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = _results;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap.vMd,
              Text(l10n.enrich, style: context.text.titleLarge),
              Gap.vSm,
              TextField(
                controller: _query,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: l10n.enrich,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    onPressed: _search,
                  ),
                ),
              ),
              Gap.vSm,
              Expanded(
                child: switch ((_searching, _failure, results)) {
                  (true, _, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        Gap.vMd,
                        Text(l10n.enrichSearching),
                      ],
                    ),
                  ),
                  (_, final EnrichmentFailure _, _) => EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: _failureMessage(l10n),
                  ),
                  (_, _, final List<EnrichmentSuggestion> found)
                      when found.isEmpty =>
                    EmptyState(
                      icon: Icons.search_off_outlined,
                      title: l10n.enrichNoResults,
                    ),
                  (_, _, final List<EnrichmentSuggestion> found) =>
                    ListView.separated(
                      controller: scrollController,
                      itemCount: found.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = found[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(suggestion.title),
                          subtitle: suggestion.subtitle.isEmpty
                              ? null
                              : Text(suggestion.subtitle),
                          trailing: const Icon(Icons.add, size: 20),
                          onTap: () => Navigator.of(context).pop(suggestion),
                        );
                      },
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
              // Both TMDB and RAWG require this credit to stay visible, and
              // RAWG requires it to be an active link.
              _Attribution(source: widget.source),
              Gap.vSm,
            ],
          ),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution({required this.source});

  final EnrichmentSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => launchUrl(
          Uri.parse(source.attributionUrl),
          mode: LaunchMode.externalApplication,
        ),
        child: Text(l10n.enrichCredit(source.attribution)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../features/shared/widgets.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/trackable.dart';
import '../domain/tracking_filter.dart';

/// Labels a list needs, gathered in one place so the screen itself stays
/// free of localization and every domain fills the same blanks.
class TrackerListLabels {
  const TrackerListLabels({
    required this.title,
    required this.searchHint,
    required this.count,
    required this.addAction,
    required this.emptyTitle,
    required this.emptyBody,
    required this.emptyFiltered,
    required this.clearFilters,
    required this.sortLabel,
  });

  final String title;
  final String searchHint;

  /// Pluralised header above the list, e.g. "12 meals".
  final String Function(int count) count;
  final String addAction;
  final String emptyTitle;
  final String emptyBody;

  /// Shown instead of [emptyTitle] when filters are what emptied the list.
  final String emptyFiltered;
  final String clearFilters;
  final String Function(TrackingSort sort) sortLabel;
}

/// The list screen every tracked domain gets.
///
/// Search, ordering, the empty states and the count header behave identically
/// in all five, so they live here. A domain supplies its own rows through
/// [cardBuilder] and its own filters through [filterChips].
class TrackerListScreen<T extends Trackable> extends StatefulWidget {
  const TrackerListScreen({
    super.key,
    required this.labels,
    required this.emptyIcon,
    required this.entries,
    required this.filter,
    required this.onQueryChanged,
    required this.onSortChanged,
    required this.onClearFilters,
    required this.onAdd,
    required this.cardBuilder,
    this.filterChips = const [],
  });

  final TrackerListLabels labels;
  final IconData emptyIcon;

  /// Null while the first query is still in flight.
  final List<T>? entries;
  final TrackingFilter filter;

  final ValueChanged<String> onQueryChanged;
  final ValueChanged<TrackingSort> onSortChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onAdd;

  final Widget Function(BuildContext context, T entry) cardBuilder;

  /// The domain's own filter controls, shown before the sort menu.
  final List<Widget> filterChips;

  @override
  State<TrackerListScreen<T>> createState() => _TrackerListScreenState<T>();
}

class _TrackerListScreenState<T extends Trackable>
    extends State<TrackerListScreen<T>> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clear() {
    _searchController.clear();
    widget.onClearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    final entries = widget.entries;

    return Scaffold(
      appBar: AppBar(title: Text(labels.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAdd,
        icon: const Icon(Icons.add),
        label: Text(labels.addAction),
      ),
      body: SafeArea(
        child: ContentColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap.vSm,
              TextField(
                controller: _searchController,
                onChanged: widget.onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: labels.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: widget.filter.searchTerm == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            widget.onQueryChanged('');
                          },
                        ),
                ),
              ),
              Gap.vSm,
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final chip in widget.filterChips) ...[chip, Gap.hSm],
                    TrackerSortMenu(
                      sort: widget.filter.sort,
                      label: labels.sortLabel,
                      onSelected: widget.onSortChanged,
                    ),
                    if (!widget.filter.isEmpty) ...[
                      Gap.hSm,
                      ActionChip(
                        avatar: const Icon(Icons.close, size: 15),
                        label: Text(labels.clearFilters),
                        onPressed: _clear,
                      ),
                    ],
                  ],
                ),
              ),
              Gap.vSm,
              Expanded(
                child: entries == null
                    ? const Center(child: CircularProgressIndicator())
                    : entries.isEmpty
                    ? EmptyState(
                        icon: widget.emptyIcon,
                        title: widget.filter.isEmpty
                            ? labels.emptyTitle
                            : labels.emptyFiltered,
                        body: widget.filter.isEmpty ? labels.emptyBody : null,
                        action: widget.filter.isEmpty
                            ? null
                            : TextButton(
                                onPressed: _clear,
                                child: Text(labels.clearFilters),
                              ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: entries.length + 1,
                        separatorBuilder: (_, _) => Gap.vSm,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Gap.xs),
                              child: SectionLabel(labels.count(entries.length)),
                            );
                          }
                          return widget.cardBuilder(
                            context,
                            entries[index - 1],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ordering menu, identical in every domain.
class TrackerSortMenu extends StatelessWidget {
  const TrackerSortMenu({
    super.key,
    required this.sort,
    required this.label,
    required this.onSelected,
  });

  final TrackingSort sort;
  final String Function(TrackingSort sort) label;
  final ValueChanged<TrackingSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TrackingSort>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final value in TrackingSort.values)
          PopupMenuItem(value: value, child: Text(label(value))),
      ],
      child: ChipShell(label: label(sort), icon: Icons.sort),
    );
  }
}

/// A chip-shaped tap target for menus, which FilterChip cannot host.
class ChipShell extends StatelessWidget {
  const ChipShell({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final semantics = context.semantics;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md - 4),
      decoration: BoxDecoration(
        color: selected
            ? context.colors.secondaryContainer
            : context.colors.surface,
        borderRadius: Radii.pill,
        border: Border.all(
          color: selected ? Colors.transparent : semantics.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), Gap.hXs],
          Text(label, style: context.text.labelLarge),
        ],
      ),
    );
  }
}

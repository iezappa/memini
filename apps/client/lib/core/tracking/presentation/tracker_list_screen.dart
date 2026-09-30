import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/shared/settings_button.dart';
import '../../../features/shared/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/tracking_filter.dart';
import 'tracker_card.dart';
import 'tracker_tile.dart';
import 'tracking_view.dart';

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
    this.sorts = TrackingSort.values,
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

  /// Which orderings this domain offers. All five by default; the watchlist
  /// offers three, because a wish has no score to sort by.
  final List<TrackingSort> sorts;
}

/// What a domain says about one entry, without saying how to draw it.
///
/// The screen draws it as a row or as a tile depending on what the owner
/// picked, and a domain that returned a widget could not be drawn twice.
typedef TrackerEntryView = ({
  String title,
  String subtitle,
  double? rating,
  IconData icon,
  String? posterUrl,

  /// The entry's own id, so a domain with no artwork can fall back on the
  /// photograph its owner attached.
  String? photoOwnerId,
  Widget? pill,
  VoidCallback onTap,
});

/// The list screen every tracked domain gets.
///
/// Search, ordering, the empty states and the count header behave identically
/// in all five, so they live here. A domain supplies its own rows through
/// [entryBuilder] and its own filters through [filterChips].
class TrackerListScreen<T> extends ConsumerStatefulWidget {
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
    required this.entryBuilder,
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

  final TrackerEntryView Function(BuildContext context, T entry) entryBuilder;

  /// The domain's own filter controls, shown before the sort menu.
  final List<Widget> filterChips;

  @override
  ConsumerState<TrackerListScreen<T>> createState() =>
      _TrackerListScreenState<T>();
}

class _TrackerListScreenState<T> extends ConsumerState<TrackerListScreen<T>> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _page = 0;

  @override
  void didUpdateWidget(TrackerListScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Narrowing the list while standing on page four would otherwise show
    // an empty page and no way to tell why.
    if (!identical(oldWidget.filter, widget.filter)) _page = 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clear() {
    _searchController.clear();
    widget.onClearFilters();
  }

  Widget _row(BuildContext context, T entry) {
    final view = widget.entryBuilder(context, entry);

    return TrackerCard(
      title: view.title,
      subtitle: view.subtitle,
      rating: view.rating,
      icon: view.icon,
      posterUrl: view.posterUrl,
      photoOwnerId: view.photoOwnerId,
      pill: view.pill,
      onTap: view.onTap,
    );
  }

  Widget _tile(BuildContext context, T entry) {
    final view = widget.entryBuilder(context, entry);

    return TrackerTile(
      title: view.title,
      subtitle: view.subtitle,
      rating: view.rating,
      icon: view.icon,
      posterUrl: view.posterUrl,
      photoOwnerId: view.photoOwnerId,
      onTap: view.onTap,
    );
  }

  void _goTo(int page) {
    setState(() => _page = page);
    // A page turn puts the reader at the top of the new page, the way
    // turning a page does. Without this they land wherever they were
    // scrolled to, halfway into entries they have not seen.
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    final entries = widget.entries;
    final view = ref.watch(trackerViewProvider);

    final pages = entries == null
        ? 1
        : (entries.length / kEntriesPerPage).ceil().clamp(1, 1 << 30);
    // Clamped on the way out rather than on the way in: entries can vanish
    // under the reader — another tab, a delete — and the page they are on
    // has to stay a page that exists.
    final page = _page.clamp(0, pages - 1);
    final shown = entries == null
        ? const []
        : entries.skip(page * kEntriesPerPage).take(kEntriesPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.title),
        // Every screen of the app carries it, in the same corner.
        actions: const [SettingsButton()],
      ),
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
                // Tall enough for the switch to keep a 48px tap target,
                // which the accessibility tests hold every screen to.
                height: 48,
                child: Row(
                  children: [
                    // The filters scroll; the switch does not. It lived in
                    // the scrolling row and went off the right edge as soon
                    // as a domain had a filter or two — a control you have
                    // to go looking for is one you have lost.
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final chip in widget.filterChips) ...[
                            Center(child: chip),
                            Gap.hSm,
                          ],
                          Center(
                            child: TrackerSortMenu(
                              sort: widget.filter.sort,
                              label: labels.sortLabel,
                              sorts: labels.sorts,
                              onSelected: widget.onSortChanged,
                            ),
                          ),
                          if (!widget.filter.isEmpty) ...[
                            Gap.hSm,
                            Center(
                              child: ActionChip(
                                avatar: const Icon(Icons.close, size: 15),
                                label: Text(labels.clearFilters),
                                onPressed: _clear,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    TrackerViewToggle(
                      view: view,
                      onSelected: ref.read(trackerViewProvider.notifier).set,
                    ),
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
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: Gap.sm),
                              child: SectionLabel(labels.count(entries.length)),
                            ),
                          ),
                          if (view == TrackerView.grid)
                            SliverGrid.builder(
                              // By width, not by a column count: the same
                              // list is read on a phone and on a wide
                              // window, and a fixed three columns is wrong
                              // on both.
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 210,
                                    mainAxisSpacing: Gap.sm,
                                    crossAxisSpacing: Gap.sm,
                                    childAspectRatio: 0.62,
                                  ),
                              itemCount: shown.length,
                              itemBuilder: (context, index) =>
                                  _tile(context, shown[index] as T),
                            )
                          else
                            SliverList.separated(
                              itemCount: shown.length,
                              // A shade more than before: the cards carry a
                              // shadow now, and 8px of air let two of them
                              // bleed into one another.
                              separatorBuilder: (_, _) => Gap.vMd,
                              itemBuilder: (context, index) =>
                                  _row(context, shown[index] as T),
                            ),
                          SliverToBoxAdapter(
                            child: _Pager(
                              page: page,
                              pages: pages,
                              onGoTo: _goTo,
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

/// The pager under a list, shown only when there is more than one page.
class _Pager extends StatelessWidget {
  const _Pager({required this.page, required this.pages, required this.onGoTo});

  final int page;
  final int pages;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Clear of the floating action button, which sits over the last row.
    if (pages <= 1) return const SizedBox(height: 96);

    return Padding(
      padding: const EdgeInsets.only(top: Gap.md, bottom: 96),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousPage,
            onPressed: page == 0 ? null : () => onGoTo(page - 1),
          ),
          Text(
            l10n.pageOf(page + 1, pages),
            style: context.text.bodyMedium?.copyWith(
              color: context.semantics.muted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextPage,
            onPressed: page == pages - 1 ? null : () => onGoTo(page + 1),
          ),
        ],
      ),
    );
  }
}

/// The list-or-grid switch, in the filter row where the ordering is.
class TrackerViewToggle extends StatelessWidget {
  const TrackerViewToggle({
    super.key,
    required this.view,
    required this.onSelected,
  });

  final TrackerView view;
  final ValueChanged<TrackerView> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final grid = view == TrackerView.grid;

    return IconButton(
      // One button rather than two: there are two shapes, so the button
      // shows the one it would switch to and says so.
      icon: Icon(grid ? Icons.view_list_outlined : Icons.grid_view_outlined),
      tooltip: grid ? l10n.viewList : l10n.viewGrid,
      onPressed: () => onSelected(grid ? TrackerView.list : TrackerView.grid),
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
    this.sorts = TrackingSort.values,
  });

  final TrackingSort sort;
  final String Function(TrackingSort sort) label;
  final List<TrackingSort> sorts;
  final ValueChanged<TrackingSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TrackingSort>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final value in sorts)
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
    final colors = context.colors;
    // Filled, like every other chip on the page now: a menu that opens from
    // an outlined pill next to filled ones looks like a different control
    // than it is.
    final foreground = selected ? colors.primary : colors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md - 4, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? colors.primary.withValues(alpha: 0.18)
            : colors.surfaceContainerHighest,
        borderRadius: Radii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            Gap.hXs,
          ],
          Text(
            label,
            style: context.text.labelLarge?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

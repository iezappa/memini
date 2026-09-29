import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/tracking/presentation/tracker_list_screen.dart';
import '../../../core/tracking/presentation/tracking_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/entry_dialog.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';
import 'book_providers.dart';

class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(bookFilterProvider);
    final controller = ref.read(bookFilterProvider.notifier);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return TrackerListScreen(
      labels: TrackerListLabels(
        title: l10n.domainBooks,
        searchHint: l10n.bookSearchHint,
        count: l10n.bookCount,
        addAction: l10n.addBook,
        emptyTitle: l10n.bookEmptyTitle,
        emptyBody: l10n.bookEmptyBody,
        emptyFiltered: l10n.bookEmptyFiltered,
        clearFilters: l10n.clearFilters,
        sortLabel: (sort) => trackingSortLabel(l10n, sort),
      ),
      emptyIcon: Icons.menu_book_outlined,
      entries: ref.watch(booksProvider).valueOrNull,
      filter: filter,
      onQueryChanged: controller.setQuery,
      onSortChanged: controller.setSort,
      onClearFilters: controller.clear,
      onAdd: () => showEntryDialog(context, const BookFormScreen()),
      entryBuilder: (context, book) {
        final date = DateFormat.yMMMd(locale).format(book.readOn);
        final year = book.publicationYear;
        return (
          title: book.title,
          photoOwnerId: book.id,
          subtitle: year == null ? date : '$year · $date',
          rating: book.rating,
          icon: Icons.menu_book_outlined,
          posterUrl: book.coverUrl,
          pill: Text(
            book.author ?? l10n.domainBooks,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () => showEntryDialog(
            context,
            BookDetailScreen(bookId: book.id),
            wide: true,
          ),
        );
      },
    );
  }
}

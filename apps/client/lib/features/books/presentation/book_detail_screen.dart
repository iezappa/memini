import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/photos/presentation/photo_strip.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/presentation/tracker_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/entry_dialog.dart';
import '../../shared/save_failure.dart';
import '../../shared/widgets.dart';
import '../domain/book.dart';
import 'book_form_screen.dart';
import 'book_providers.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  Future<void> _edit(BuildContext context, Book book) async {
    await showEntryDialog(context, BookFormScreen(book: book));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Book book) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteBook,
      body: l10n.deleteConfirm(book.title),
    );
    if (!confirmed || !context.mounted) return;

    final deleted = await guardDelete(
      context,
      () => ref.read(bookRepositoryProvider).delete(book.id),
    );
    if (deleted) navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(bookProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (book.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, book.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, book.value!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: book.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.retry,
            body: '$error',
          ),
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.menu_book_outlined,
                title: l10n.bookEmptyTitle,
              );
            }
            return TrackerDetailBody(
              title: value.title,
              happenedOn: value.readOn,
              rating: value.rating,
              contextLine: value.publicationYear?.toString(),
              badge: Text(value.author ?? l10n.domainBooks),
              description: value.description,
              review: value.review,
              facts: [
                if (value.author != null)
                  (label: l10n.fieldAuthor, value: value.author!),
              ],
              extra: [
                Gap.vXl,
                SectionLabel(l10n.photosLabel),
                Gap.vSm,
                PhotoStrip(ownerId: value.id),
              ],
              posterUrl: value.coverUrl,
            );
          },
        ),
      ),
    );
  }
}

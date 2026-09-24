import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Opens a screen as a modal over the app instead of as a page of its own.
///
/// Reading an entry and writing one are both side trips: the list you came
/// from is the place, and leaving it to look at one card — then leaving
/// again to edit it — turns two taps into a stack of pages to climb back
/// out of. As a modal the list stays behind, and closing puts you exactly
/// where you were.
///
/// The screens it hosts are ordinary `Scaffold`s and stay that way: their
/// own app bar renders at the top of the modal, and the back arrow it grows
/// closes the modal, because the route being popped is the dialog itself.
/// That is what lets the same widget still answer a deep link as a page.
///
/// [wide] is for the pages that show artwork. A form gets the narrower box:
/// a column of fields stretched across a desktop window is a worse form
/// than a small one.
///
/// Full screen on a phone, where a dialog with margins is just a page with
/// the corners cut off.
Future<T?> showEntryDialog<T>(
  BuildContext context,
  Widget screen, {
  bool wide = false,
}) {
  final narrow = MediaQuery.sizeOf(context).width < 700;

  return showDialog<T>(
    context: context,
    builder: (context) => narrow
        ? Dialog.fullscreen(child: screen)
        : Dialog(
            clipBehavior: Clip.antiAlias,
            insetPadding: const EdgeInsets.all(Gap.lg),
            child: ConstrainedBox(
              // Tall enough for a form without scrolling and short enough
              // to still read as something laid over the list.
              constraints: const BoxConstraints(maxWidth: 880, maxHeight: 760),
              child: screen,
            ),
          ),
  );
}

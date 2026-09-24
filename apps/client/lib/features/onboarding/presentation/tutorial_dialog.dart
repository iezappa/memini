import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';

/// The short walkthrough, as a dialog over the app.
///
/// A dialog rather than a screen of its own, which is what this was. The
/// difference is not decoration: a full page at first launch is the app
/// hiding itself behind a brochure, and someone reopening the tour from
/// settings was taken out of the app to read three slides. Over the app,
/// the tour is plainly something you close.
///
/// Run as [onboarding] it ends with the disclaimer, and finishing it is
/// accepting that: the checkbox has to be ticked, the barrier does not
/// dismiss, and there is no Skip. Opened later from settings it is just the
/// three slides.
Future<void> showTutorial(BuildContext context, {bool onboarding = false}) =>
    showDialog<void>(
      context: context,
      // A first run has to be completed, not dismissed: what it collects is
      // the acceptance the app is not allowed to assume.
      barrierDismissible: !onboarding,
      builder: (context) => _TutorialDialog(onboarding: onboarding),
    );

class _TutorialDialog extends ConsumerStatefulWidget {
  const _TutorialDialog({required this.onboarding});

  final bool onboarding;

  @override
  ConsumerState<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends ConsumerState<_TutorialDialog> {
  final _controller = PageController();
  int _page = 0;

  /// The backup notice has to be ticked before a first run can end.
  bool _noticeAcknowledged = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (widget.onboarding) {
      await ref.read(onboardingDoneProvider.notifier).complete();
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _move(int delta) => _controller.animateToPage(
    _page + delta,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final slides = <Widget>[
      _Slide(
        art: const _Glyph(icon: Icons.meeting_room_outlined),
        title: l10n.tutorial1Title,
        body: l10n.tutorial1Body,
      ),
      _Slide(
        art: const _Glyph(icon: Icons.star_outline_rounded),
        title: l10n.tutorial2Title,
        body: l10n.tutorial2Body,
      ),
      _Slide(
        art: const _Glyph(icon: Icons.lock_outline_rounded),
        title: l10n.tutorial3Title,
        body: l10n.tutorial3Body,
      ),
      // Last on purpose, so finishing the tour is what accepts it. Skip is
      // absent from a first run for the same reason: there is nothing here
      // to skip past.
      if (widget.onboarding)
        _Slide(
          art: const _Glyph(icon: Icons.info_outline),
          title: l10n.disclaimerTitle,
          body: l10n.disclaimerBody,
          extra: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _noticeAcknowledged,
            onChanged: (value) =>
                setState(() => _noticeAcknowledged = value ?? false),
            title: Text(l10n.backupNoticeCheckbox),
          ),
        ),
    ];

    final isLast = _page == slides.length - 1;
    final canFinish = !widget.onboarding || _noticeAcknowledged;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      content: SizedBox(
        // Fixed, so the dialog does not resize under the reader as the
        // slides change: three lines of copy and four are different
        // heights. Sized for the longest slide — the disclaimer — and the
        // short ones centre their content in it rather than leaving the
        // hole at the bottom that made this look unfinished.
        width: 440,
        height: 420,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _page = index),
                children: slides,
              ),
            ),
            Gap.vLg,
            _PageIndicator(page: _page, total: slides.length),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      actions: [
        if (_page > 0)
          TextButton(onPressed: () => _move(-1), child: Text(l10n.tutorialBack))
        else if (!widget.onboarding)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.tutorialSkip),
          )
        else
          const SizedBox.shrink(),
        FilledButton(
          onPressed: !isLast
              ? () => _move(1)
              : canFinish
              ? _finish
              : null,
          child: Text(
            isLast
                ? (widget.onboarding ? l10n.disclaimerAccept : l10n.close)
                : l10n.tutorialNext,
          ),
        ),
      ],
    );
  }
}

/// Dots plus a spelled-out count.
///
/// The dots alone read as decoration; the number is what actually answers
/// "how much of this is left".
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.page, required this.total});

  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < total; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == page ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == page
                      ? context.colors.primary
                      : context.semantics.hairline,
                  borderRadius: Radii.pill,
                ),
              ),
          ],
        ),
        Gap.vSm,
        Text(
          l10n.tutorialPageOf(page + 1, total),
          style: context.text.labelSmall?.copyWith(
            color: context.semantics.muted,
          ),
        ),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.art,
    required this.title,
    required this.body,
    this.extra,
  });

  final Widget art;
  final String title;
  final String body;

  /// Anything the slide collects, under the copy.
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          // Centred while it fits, scrollable when it does not: the
          // disclaimer is a paragraph and a checkbox, the other three are
          // two lines.
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              art,
              Gap.vLg,
              Text(
                title,
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              Gap.vSm,
              Text(
                body,
                style: context.text.bodyMedium?.copyWith(
                  height: 1.55,
                  color: context.semantics.muted,
                ),
                textAlign: TextAlign.center,
              ),
              if (extra case final extra?) ...[Gap.vLg, extra],
            ],
          ),
        ),
      ),
    );
  }
}

/// The tinted circle the tour uses instead of a picture.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        // A hairline ring on the tint: the flat disc read as a placeholder
        // where an illustration had not been drawn yet.
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Icon(icon, size: 34, color: context.colors.primary),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';

/// First-run flow: three slides, then the disclaimer with explicit acceptance.
///
/// The disclaimer is the last page on purpose — accepting it is what ends the
/// flow, so it can never be swiped past.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.tutorialOnly = false});

  /// Re-opened from Settings: the slides only, nothing to accept again.
  final bool tutorialOnly;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  /// The backup notice has to be ticked before the flow can end.
  bool _noticeAcknowledged = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Three slides, plus the disclaimer unless there is nothing to accept.
  int get _pageCount => widget.tutorialOnly ? 3 : 4;

  Future<void> _finish() async {
    if (widget.tutorialOnly) {
      Navigator.of(context).pop();
      return;
    }
    await ref.read(onboardingDoneProvider.notifier).complete();
  }

  /// Skipping is about the tutorial, not the disclaimer.
  ///
  /// It jumps to the last page instead of ending the flow, so the disclaimer
  /// still has to be accepted on purpose. Ending here would have persisted
  /// the acceptance of a text that was never on screen.
  void _skip() {
    if (widget.tutorialOnly) {
      _finish();
      return;
    }
    _controller.jumpToPage(_pageCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final slides = <Widget>[
      _Slide(
        icon: Icons.meeting_room_outlined,
        title: l10n.tutorial1Title,
        body: l10n.tutorial1Body,
      ),
      _Slide(
        icon: Icons.star_outline_rounded,
        title: l10n.tutorial2Title,
        body: l10n.tutorial2Body,
      ),
      _Slide(
        icon: Icons.lock_outline_rounded,
        title: l10n.tutorial3Title,
        body: l10n.tutorial3Body,
      ),
      if (!widget.tutorialOnly)
        _Slide(
          icon: Icons.info_outline,
          title: l10n.disclaimerTitle,
          body: l10n.disclaimerBody,
          // On the same page as the disclaimer, so Skip — which lands here —
          // cannot go around it.
          footer: _BackupNotice(
            acknowledged: _noticeAcknowledged,
            onChanged: (value) => setState(() => _noticeAcknowledged = value),
          ),
        ),
    ];

    final isLast = _page == slides.length - 1;
    final canFinish = widget.tutorialOnly || _noticeAcknowledged;

    return Scaffold(
      body: SafeArea(
        child: ContentColumn(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLast ? null : _skip,
                  child: Text(l10n.tutorialSkip),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: slides,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: i == _page ? 20 : 6,
                      decoration: BoxDecoration(
                        borderRadius: Radii.pill,
                        color: i == _page
                            ? context.colors.primary
                            : context.semantics.hairline,
                      ),
                    ),
                ],
              ),
              Gap.vLg,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLast && !canFinish
                      ? null
                      : () {
                          if (isLast) {
                            _finish();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                  child: Text(
                    isLast
                        ? (widget.tutorialOnly
                              ? l10n.close
                              : l10n.disclaimerAccept)
                        : l10n.tutorialNext,
                  ),
                ),
              ),
              Gap.vLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.vXl,
          Icon(icon, size: 44, color: context.colors.primary),
          Gap.vLg,
          Text(title, style: context.text.displaySmall),
          Gap.vMd,
          Text(body, style: context.text.bodyLarge),
          if (footer != null) ...[Gap.vLg, footer!],
          Gap.vXl,
        ],
      ),
    );
  }
}

/// The standard's backup notice: the data lives only here, and it is on the
/// owner to export it.
class _BackupNotice extends StatelessWidget {
  const _BackupNotice({required this.acknowledged, required this.onChanged});

  final bool acknowledged;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone_android_outlined, color: context.colors.primary),
            Gap.hSm,
            Expanded(
              child: Text(
                l10n.backupNoticeTitle,
                style: context.text.titleMedium,
              ),
            ),
          ],
        ),
        Gap.vSm,
        Text(l10n.backupNoticeBody, style: context.text.bodyMedium),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: acknowledged,
          onChanged: (value) => onChanged(value ?? false),
          title: Text(l10n.backupNoticeCheckbox),
        ),
      ],
    );
  }
}

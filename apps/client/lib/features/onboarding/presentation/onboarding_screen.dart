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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (widget.tutorialOnly) {
      Navigator.of(context).pop();
      return;
    }
    await ref.read(onboardingDoneProvider.notifier).complete();
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
        ),
    ];

    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: ContentColumn(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLast ? null : _finish,
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
                  onPressed: () {
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
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

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
          Gap.vXl,
        ],
      ),
    );
  }
}

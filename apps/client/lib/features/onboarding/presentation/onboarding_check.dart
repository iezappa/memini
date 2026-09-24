import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'tutorial_dialog.dart';

/// Opens the tour on a first run, over the app rather than instead of it.
///
/// Sits inside the router, where a navigator exists to open a dialog on, and
/// outermost among the launch checks: a first run wins and the others wait.
/// Someone installing the app today was never around for the releases the
/// what's-new dialog lists, and the backup notice is on the tour's own last
/// page.
class OnboardingCheck extends ConsumerStatefulWidget {
  const OnboardingCheck({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OnboardingCheck> createState() => _OnboardingCheckState();
}

class _OnboardingCheckState extends ConsumerState<OnboardingCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(onboardingDoneProvider)) return;
      showTutorial(context, onboarding: true);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

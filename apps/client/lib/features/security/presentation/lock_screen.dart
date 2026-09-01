import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';

/// Shown instead of the app until the PIN is entered for this session.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final wrong = AppLocalizations.of(context).pinWrong;
    final ok = await ref.read(pinServiceProvider).verify(_controller.text);

    if (!mounted) return;
    if (ok) {
      ref.read(unlockedProvider.notifier).unlock();
    } else {
      setState(() => _error = wrong);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ContentColumn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: context.colors.primary,
                ),
                Gap.vLg,
                Text(l10n.appTitle, style: context.text.displaySmall),
                Gap.vSm,
                Text(l10n.pinEnter, style: context.text.bodySmall),
                Gap.vLg,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(errorText: _error),
                  ),
                ),
                Gap.vLg,
                FilledButton(onPressed: _submit, child: Text(l10n.pinUnlock)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/tracking/domain/trackable.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets.dart';
import '../domain/room.dart';

/// Create or edit a room. Passing [room] switches the screen to edit mode.
class RoomFormScreen extends ConsumerStatefulWidget {
  const RoomFormScreen({super.key, this.room});

  final Room? room;

  bool get isEditing => room != null;

  @override
  ConsumerState<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends ConsumerState<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _review;
  late final TextEditingController _franchise;
  late final TextEditingController _timeLeft;

  late DateTime _playedOn;
  late bool _escaped;
  late double? _rating;
  String? _photoPath;

  /// The photo path the room had when the screen opened, so replacing a photo
  /// can delete the old file only once the save actually goes through.
  String? _originalPhotoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final room = widget.room;

    _name = TextEditingController(text: room?.title ?? '');
    _description = TextEditingController(text: room?.description ?? '');
    _review = TextEditingController(text: room?.review ?? '');
    _franchise = TextEditingController();
    _timeLeft = TextEditingController(
      text: room?.timeLeftMinutes?.toString() ?? '',
    );

    _playedOn = room?.happenedOn ?? DateTime.now();
    _escaped = room?.escaped ?? true;
    _rating = room?.rating;
    _photoPath = room?.photoPath;
    _originalPhotoPath = room?.photoPath;

    final franchiseId = room?.franchiseId;
    if (franchiseId != null) {
      // Resolved after the first frame: the name is not on the Room entity.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final franchise = await ref
            .read(franchiseRepositoryProvider)
            .findById(franchiseId);
        if (mounted && franchise != null) _franchise.text = franchise.name;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _review.dispose();
    _franchise.dispose();
    _timeLeft.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = AppLocalizations.of(context).photoFailed;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
      );
      if (picked == null) return;

      final stored = await ref.read(photoStorageProvider).store(picked.path);
      if (mounted) setState(() => _photoPath = stored);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _playedOn,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _playedOn = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final franchiseName = _trimmedOrNull(_franchise);
    final franchiseId = franchiseName == null
        ? null
        : (await ref
                  .read(franchiseRepositoryProvider)
                  .ensureByName(franchiseName))
              .id;

    // Time left only means something for a room that was escaped.
    final timeLeft = _escaped ? int.tryParse(_timeLeft.text.trim()) : null;

    final repository = ref.read(roomRepositoryProvider);
    final existing = widget.room;

    if (existing == null) {
      await repository.create(
        RoomDraft(
          title: _name.text,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          franchiseId: franchiseId,
          rating: _rating,
          review: _trimmedOrNull(_review),
          happenedOn: _playedOn,
          escaped: _escaped,
          timeLeftMinutes: timeLeft,
        ),
      );
    } else {
      await repository.update(
        Room(
          id: existing.id,
          title: _name.text,
          photoPath: _photoPath,
          description: _trimmedOrNull(_description),
          franchiseId: franchiseId,
          rating: _rating,
          review: _trimmedOrNull(_review),
          happenedOn: _playedOn,
          escaped: _escaped,
          timeLeftMinutes: timeLeft,
        ),
      );

      if (_originalPhotoPath != null && _originalPhotoPath != _photoPath) {
        await ref.read(photoStorageProvider).remove(_originalPhotoPath);
      }
    }

    if (mounted) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editRoom : l10n.newRoom),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
          Gap.hSm,
        ],
      ),
      body: SafeArea(
        child: ContentColumn(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(bottom: Gap.xl),
              children: [
                _PhotoField(
                  path: _photoPath,
                  onPick: _pickPhoto,
                  onRemove: _photoPath == null
                      ? null
                      : () => setState(() => _photoPath = null),
                ),
                Gap.vLg,
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.fieldName),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.fieldNameRequired
                      : null,
                ),
                Gap.vMd,
                _FranchiseField(controller: _franchise),
                Gap.vMd,
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: Radii.field,
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.fieldPlayedOn,
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                          ),
                          child: Text(
                            DateFormat.yMMMd(locale).format(_playedOn),
                            style: context.text.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap.vMd,
                _OutcomeField(
                  escaped: _escaped,
                  onChanged: (value) => setState(() => _escaped = value),
                ),
                if (_escaped) ...[
                  Gap.vMd,
                  TextFormField(
                    controller: _timeLeft,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.fieldTimeLeft,
                      helperText: l10n.fieldTimeLeftHint,
                    ),
                  ),
                ],
                Gap.vLg,
                _RatingField(
                  value: _rating,
                  onChanged: (value) => setState(() => _rating = value),
                ),
                Gap.vLg,
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.fieldDescription),
                ),
                Gap.vMd,
                TextFormField(
                  controller: _review,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.fieldReview),
                ),
                Gap.vLg,
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.path,
    required this.onPick,
    required this.onRemove,
  });

  final String? path;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.vMd,
        AspectRatio(
          aspectRatio: 16 / 9,
          child: EntryPhoto(path: path, width: double.infinity),
        ),
        Gap.vSm,
        Row(
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(path == null ? l10n.photoAdd : l10n.photoReplace),
            ),
            if (onRemove != null)
              TextButton(onPressed: onRemove, child: Text(l10n.photoRemove)),
          ],
        ),
      ],
    );
  }
}

/// Free-text franchise entry with suggestions. Typing a new name creates the
/// franchise on save, so the user never has to manage a separate list first.
class _FranchiseField extends ConsumerWidget {
  const _FranchiseField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final franchises = ref.watch(franchisesProvider).valueOrNull ?? const [];

    return Autocomplete<String>(
      initialValue: controller.value,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return franchises.map((f) => f.name);
        return franchises
            .map((f) => f.name)
            .where((name) => name.toLowerCase().contains(query));
      },
      onSelected: (value) => controller.text = value,
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        // Autocomplete owns its controller; mirror it into ours so _save
        // reads whatever is on screen, typed or picked.
        textController.addListener(() => controller.text = textController.text);
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.fieldFranchise,
            helperText: l10n.franchiseHint,
          ),
        );
      },
    );
  }
}

class _OutcomeField extends StatelessWidget {
  const _OutcomeField({required this.escaped, required this.onChanged});

  final bool escaped;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.fieldOutcome),
        Gap.vSm,
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.lock_open_rounded, size: 16),
              label: Text(l10n.escapedYes),
            ),
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.lock_outline_rounded, size: 16),
              label: Text(l10n.escapedNo),
            ),
          ],
          selected: {escaped},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionLabel(l10n.fieldRating),
            ScoreBadge(rating: value),
          ],
        ),
        Slider(
          value: value ?? kMinRating,
          min: kMinRating,
          max: kMaxRating,
          divisions: 20,
          label: (value ?? 0).toStringAsFixed(1),
          onChanged: onChanged,
        ),
        if (value != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onChanged(null),
              child: Text(l10n.notRated),
            ),
          ),
      ],
    );
  }
}

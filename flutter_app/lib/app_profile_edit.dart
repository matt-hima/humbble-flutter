import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/models.dart';
import 'data/repositories.dart';

class ProfileEditButton extends ConsumerWidget {
  const ProfileEditButton({super.key, required this.profile});
  final Profile profile;
  @override
  Widget build(BuildContext context, WidgetRef ref) => OutlinedButton.icon(
    icon: const Icon(Icons.edit),
    label: const Text('Edit profile'),
    onPressed: () => showDialog<void>(
      context: context,
      builder: (_) => _ProfileEditor(profile: profile),
    ),
  );
}

class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({required this.profile});
  final Profile profile;
  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  late final name = TextEditingController(text: widget.profile.name),
      bio = TextEditingController(text: widget.profile.bio),
      age = TextEditingController(text: widget.profile.age.toString()),
      goal = TextEditingController(text: widget.profile.goal),
      interests = TextEditingController(
        text: widget.profile.interests.join(', '),
      );
  bool saving = false;
  Future<void> save() async {
    setState(() => saving = true);
    await ref
        .read(profileRepositoryProvider)
        .save(
          Profile(
            id: widget.profile.id,
            name: name.text.trim(),
            age: int.tryParse(age.text) ?? widget.profile.age,
            bio: bio.text.trim(),
            photoUrl: widget.profile.photoUrl,
            goal: goal.text.trim(),
            interests: interests.text
                .split(',')
                .map((v) => v.trim())
                .where((v) => v.isNotEmpty)
                .toList(),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit profile'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(name, 'Name'),
            _field(age, 'Age', type: TextInputType.number),
            _field(bio, 'Bio'),
            _field(goal, 'Dating goal'),
            _field(interests, 'Interests, separated by commas'),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: Text(saving ? 'Saving…' : 'Save'),
      ),
    ],
  );
  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

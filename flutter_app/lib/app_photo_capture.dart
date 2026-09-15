import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization.dart';
import 'core/photobooth_map.dart';
import 'data/models.dart';
import 'data/photobooth_service.dart';
import 'data/repositories.dart';

class PhotoBoothCapture extends ConsumerStatefulWidget {
  const PhotoBoothCapture({super.key, required this.profile});
  final Profile profile;
  @override
  ConsumerState<PhotoBoothCapture> createState() => _PhotoBoothCaptureState();
}

class _PhotoBoothCaptureState extends ConsumerState<PhotoBoothCapture> {
  bool _busy = false;
  Future<void> _capture() async {
    setState(() => _busy = true);
    try {
      final url = await PhotoboothService().captureAndUpload(widget.profile.id);
      await ref
          .read(profileRepositoryProvider)
          .save(
            Profile(
              id: widget.profile.id,
              name: widget.profile.name,
              age: widget.profile.age,
              bio: widget.profile.bio,
              photoUrl: url,
              goal: widget.profile.goal,
              interests: widget.profile.interests,
            ),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPhotobooth() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('美圖境界 Glass&Frame'),
        content: const SizedBox(
          width: 600,
          height: 450,
          child: PhotoboothMap(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Capture here'),
          ),
        ],
      ),
    );
    if (approved == true) await _capture();
  }

  @override
  Widget build(BuildContext context) {
    final t = Strings(ref.watch(languageProvider));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.photoRule,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(t.locationRequired),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _openPhotobooth,
              icon: const Icon(Icons.photo_camera),
              label: Text(_busy ? '…' : t.capturePhoto),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class PhotoboothService {
  static const _latitude = 25.0418029;
  static const _longitude = 121.5477681;
  static const _radiusMetres = 100.0;
  final ImagePicker _picker = ImagePicker();
  Future<String> captureAndUpload(String uid) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required.');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _latitude,
      _longitude,
    );
    if (distance > _radiusMetres) {
      throw Exception(
        'You must be at the 美圖境界 photobooth to take a profile photo.',
      );
    }
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image == null) throw Exception('Camera capture was cancelled.');
    final ref = FirebaseStorage.instance.ref(
      'profile-photos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}

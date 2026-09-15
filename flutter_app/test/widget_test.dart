import 'package:flutter_test/flutter_test.dart';
import 'package:photo_hubble/app.dart';

void main() {
  test('exposes the Flutter application root', () {
    expect(const HumbbleApp(), isA<HumbbleApp>());
  });
}

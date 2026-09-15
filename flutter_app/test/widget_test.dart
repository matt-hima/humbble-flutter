import 'package:flutter_test/flutter_test.dart';
import 'package:photo_hubble/main.dart';

void main() {
  test('includes the migrated discovery profiles', () {
    expect(people, hasLength(3));
  });
}

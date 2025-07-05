import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/services/app_configuration_service.dart';

void main() {
  group('AppConfigurationService', () {
    test('can be instantiated', () {
      final service = AppConfigurationService();
      expect(service, isNotNull);
    });
    // Add more tests as needed for your service methods
  });
}

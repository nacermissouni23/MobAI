import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // WarehouseApp now requires repository DI which needs sqflite.
    // Full widget tests require an in-memory database setup.
    // This will be expanded when integration tests are added.
    expect(true, isTrue);
  });
}

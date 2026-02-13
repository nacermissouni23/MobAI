import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WarehouseApp());
    await tester.pumpAndSettle();

    // Verify the login screen is shown
    expect(find.text('Warehouse Login'), findsOneWidget);
  });
}

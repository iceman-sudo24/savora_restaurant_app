import 'package:flutter_test/flutter_test.dart';
import 'package:savora_restaurant_app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Basic smoke test — verifies the App widget can be instantiated.
    // Full widget testing with Firebase mocking will be added in a later sprint.
    await tester.pumpWidget(const App());
    // If we get here without throwing, the test passes.
  });
}
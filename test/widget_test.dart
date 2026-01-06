// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/core/services/storage_service.dart';
import 'package:nexora/core/services/streak_service.dart';
import 'package:nexora/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Initialize services for testing
    final storage = StorageService();
    await storage.init();
    final streakService = StreakService(storage);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      storage: storage,
      streakService: streakService,
    ));

    // Verify that the app title appears
    expect(find.text('STUDYBUDDY: SMASH MODE'), findsOneWidget);
  });
}

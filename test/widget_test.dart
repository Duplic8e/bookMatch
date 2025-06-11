import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app_project_bookstore/core/theme/theme_provider.dart';
import 'package:mobile_app_project_bookstore/main.dart';

void main() {
  // This setup block initializes Hive before tests run.
  // It's necessary because the app now depends on Hive for theme storage.
  setUpAll(() async {
    // We need to use a temporary directory for tests to avoid conflicts.
    // The 'test_storage' path is arbitrary for the test environment.
    await Hive.initFlutter('test_storage');
    // Open the same box that the app uses.
    await Hive.openBox(themeBoxName);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: KetaBookApp(),
      ),
    );

    // Verify that our app's main widget has been rendered.
    expect(find.byType(KetaBookApp), findsOneWidget);
  });
}

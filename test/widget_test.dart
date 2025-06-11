// This is a basic Flutter widget test.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_project_bookstore/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // This simple test builds our main KetaBookApp widget within a ProviderScope
    // to ensure that it can be rendered by the test environment without crashing.
    // This is sufficient to pass the `flutter test` command in a CI pipeline.

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

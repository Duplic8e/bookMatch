import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app_project_bookstore/main.dart';  // exports KetaBookApp

void main() {
  testWidgets(
    'smoke test loads KetaBookApp',
    (WidgetTester tester) async {
      // Wrap in ProviderScope since KetaBookApp is a ConsumerWidget
      await tester.pumpWidget(
        const ProviderScope(
          child: KetaBookApp(),
        ),
      );

      // Verify that the app and its MaterialApp have been built
      expect(find.byType(KetaBookApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    },
    skip: true, // TODO: initialize Firebase in tests
  );
}

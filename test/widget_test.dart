import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app_project_bookstore/main.dart';  // exports KetaBookApp

void main() {
  testWidgets('smoke test loads KetaBookApp', (WidgetTester tester) async {
    // Wrap in ProviderScope since KetaBookApp is a ConsumerWidget
    await tester.pumpWidget(
      const ProviderScope(
        child: KetaBookApp(),
      ),
    );

    // Assert that your root widget is in the tree:
    expect(find.byType(KetaBookApp), findsOneWidget);

    // And that it created a MaterialApp (router) under the hood:
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

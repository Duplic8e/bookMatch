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

    // Now you can write expectations against your real UI...
    // For example, check that your AppBar title is present:
    expect(find.text('KetaBook'), findsOneWidget);
  });
}

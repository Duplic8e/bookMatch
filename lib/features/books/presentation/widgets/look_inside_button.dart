import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LookInsideButton extends StatelessWidget {
  final String bookId;
  final String previewUrl;
  final String title; // Pass the title for the preview screen AppBar

  const LookInsideButton({
    super.key,
    required this.bookId,
    required this.previewUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.menu_book),
      label: const Text('Read Book'),
      onPressed: previewUrl.isNotEmpty
          ? () {
        // ** FIX: Use goNamed for sub-routes **
        context.goNamed(
          'bookPreview',
          pathParameters: {'bookId': bookId},
          extra: {'url': previewUrl, 'title': title},
        );
      }
          : null, // Disable if no preview URL
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}

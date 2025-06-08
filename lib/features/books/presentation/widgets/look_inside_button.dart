// A button to navigate to the "Look Inside" preview.

// lib/features/books/presentation/widgets/look_inside_button.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Assuming you use GoRouter for navigation

class LookInsideButton extends StatelessWidget {
  final String bookId;
  final String previewUrl;

  const LookInsideButton({
    super.key,
    required this.bookId,
    required this.previewUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.menu_book),
      label: const Text('Look Inside'),
      onPressed: previewUrl.isNotEmpty
          ? () {
        // Navigate to a new screen that will display the PDF/content
        // You'll need to define this route in your app_router.dart
        // Example: context.go('/books/$bookId/preview');
        // Pass previewUrl to the preview screen
        // For simplicity, let's assume a route '/book-preview' that takes arguments
        context.go('/book-preview', extra: {'url': previewUrl, 'title': 'Book Preview'});

      }
          : null, // Disable if no preview URL
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48), // Make button wider
      ),
    );
  }
}
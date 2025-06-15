import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A full-width button that navigates to the PDF preview of the book.
class LookInsideButton extends StatelessWidget {
  final String bookId;
  final String previewUrl;
  final String title;

  const LookInsideButton({
    Key? key,
    required this.bookId,
    required this.previewUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.menu_book),
        label: const Text('Read Book'),
        onPressed: previewUrl.isNotEmpty
            ? () {
                context.pushNamed(
                  'bookPreview',
                  pathParameters: {'bookId': bookId},
                  extra: {
                    'url': previewUrl,
                    'title': title,
                    'isFromLibrary': false,
                  },
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsyncValue = ref.watch(userLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: libraryAsyncValue.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your purchased books will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    book.coverImageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.book),
                  ),
                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.authors.join(', ')),
                      const SizedBox(height: 8),
                      // TODO: Add reading progress bar here later
                      const LinearProgressIndicator(
                        value: 0.0, // Placeholder
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the book preview to read it
                    context.goNamed(
                      'bookPreview',
                      pathParameters: {'bookId': book.id}, // Needs a bookId in the path
                      extra: {'url': book.pdfUrl, 'title': book.title},
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

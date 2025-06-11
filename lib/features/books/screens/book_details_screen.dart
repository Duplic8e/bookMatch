// lib/features/books/screens/book_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Corrected import for Book entity (domain layer)
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
// Corrected import for book_providers.dart (sibling folder)
import 'package:mobile_app_project_bookstore/features/books/providers/book_providers.dart';
// Import the search overlay
import 'package:mobile_app_project_bookstore/features/search/screens/search_overlay.dart';

class BookDetailsScreen extends ConsumerWidget {
  final String bookId;
  final Map<String, dynamic>? extras;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.extras,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsyncValue = ref.watch(bookByIdProvider(bookId));
    final returnToSearch = extras?['returnToSearch'] == true;
    print("DEBUG: BookDetailsScreen received bookId: $bookId");

    return WillPopScope(
      onWillPop: () async {
        if (returnToSearch) {
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pop(); // Finish the pop
            // Then, schedule the overlay to show on the *next* screen
            Future.microtask(() => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const SearchOverlay(),
            ));
          });
          return false; // <-- don't auto-pop, we did it manually
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: bookAsyncValue.when(
            data: (book) => Text(book?.title ?? 'Book Details'),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Book Details'),
          ),
        ),
        body: bookAsyncValue.when(
          data: (book) {

            if (book == null) {
              return const Center(child: Text('Book not found.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Hero(
                      tag: 'bookCover-${book.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          book.coverImageUrl,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image, size: 50)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${book.title} to cart (not implemented)')),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (book.genres.isNotEmpty) ...[
                    Text(
                      'Genres',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: book.genres.map((genre) => Chip(label: Text(genre))).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Failed to load book details: ${error.toString()}'),
          ),
        ),
      ),
    );
  }
}

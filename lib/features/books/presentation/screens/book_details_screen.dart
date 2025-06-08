// lib/features/books/presentation/screens/book_detail_screen.dart
//The UI for displaying book details.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/look_inside_button.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/review_list.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/submit_review_form.dart';
// import 'package:go_router/go_router.dart'; // For navigation to preview screen

class BookDetailScreen extends ConsumerWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsyncValue = ref.watch(bookDetailProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: bookAsyncValue.when(
          data: (book) => Text(book?.title ?? 'Book Detail'),
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book.imageUrl.isNotEmpty)
                      Image.network(
                        book.imageUrl,
                        height: 180,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                                height: 180,
                                width: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 50)),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text('by ${book.author}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(book.rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(width: 8),
                              Text('(${book.genre})', // Assuming you want to show genre here
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('\$${book.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Description',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(book.description,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                LookInsideButton(bookId: book.id, previewUrl: book.previewUrl),
                const SizedBox(height: 24),
                Text('Format: ${book.format.name}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Stock: ${book.stockStatus > 0 ? "${book.stockStatus} available" : "Out of Stock"}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Sold by: ${book.sellerDetails}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
                ReviewList(bookId: book.id), // You'll create this widget
                const SizedBox(height: 16),
                SubmitReviewForm(bookId: book.id), // You'll create this widget
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Failed to load book details: $err')),
      ),
    );
  }
}
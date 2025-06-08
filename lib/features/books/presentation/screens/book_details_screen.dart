import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/look_inside_button.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/review_list.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/submit_review_form.dart';

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
                    if (book.coverImageUrl.isNotEmpty)
                      Hero(
                        tag: 'bookCover-${book.id}',
                        child: Image.network(
                          book.coverImageUrl,
                          height: 180,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(height: 180, width: 120, color: Colors.grey[300], child: const Icon(Icons.book, size: 50)),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text('by ${book.authors.join(", ")}', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(book.averageRating.toStringAsFixed(1), style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text('(${book.categories.join(", ")})', style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Published: ${book.publishedYear} • ${book.pageCount} pages', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Use the pdfUrl for the preview button
                LookInsideButton(bookId: book.id, previewUrl: book.pdfUrl),
                const SizedBox(height: 24),
                Text('Description', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(book.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                if (book.tags.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: book.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Reviews (${book.ratingsCount})', style: Theme.of(context).textTheme.titleLarge),
                ReviewList(bookId: book.id),
                const SizedBox(height: 16),
                SubmitReviewForm(bookId: book.id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load book details: $err')),
      ),
    );
  }
}

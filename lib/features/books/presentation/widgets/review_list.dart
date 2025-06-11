// Widget to display a list of reviews.
// lib/features/books/presentation/widgets/review_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReviewList extends ConsumerWidget {
  final String bookId;

  const ReviewList({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsyncValue = ref.watch(bookReviewsProvider(bookId));

    return reviewsAsyncValue.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No reviews yet. Be the first!')),
          );
        }
        return ListView.builder(
          shrinkWrap: true, // Important inside SingleChildScrollView
          physics:
          const NeverScrollableScrollPhysics(), // To prevent nested scrolling issues
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.userName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat.yMMMd().format(review.timestamp), // e.g., Sep 10, 2023
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Failed to load reviews: $err')),
    );
  }
}
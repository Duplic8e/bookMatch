// lib/features/books/screens/book_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/common/color_extension.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/providers/book_providers.dart';

class BookDetailsScreen extends ConsumerWidget {
  final String bookId;
  const BookDetailsScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookByIdProvider(bookId));
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return Center(
              child: Text('Book not found', style: TextStyle(color: TColor.text)),
            );
          }

          return Stack(
            children: [
              // Green curved header
              ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: media.height * 0.3,
                  color: TColor.primary,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: media.height * 0.1),
                      // Cover Image Hero
                      Hero(
                        tag: 'bookCover-${book.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            book.coverImageUrl,
                            width: media.width * 0.6,
                            height: media.height * 0.3,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: media.width * 0.6,
                              height: media.height * 0.3,
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image, size: 50)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Detail Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By ${book.author}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '\$${book.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                color: TColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                            ),
                            if (book.genres.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Genres',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: book.genres
                                    .map((g) => Chip(label: Text(g)))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Failed to load: \$e', style: TextStyle(color: TColor.text)),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 50);
    p.quadraticBezierTo(
      size.width * 0.5, size.height,
      size.width, size.height - 50,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> old) => false;
}

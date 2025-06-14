import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/look_inside_button.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/review_list.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/widgets/submit_review_form.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:mobile_app_project_bookstore/features/search/screens/search_overlay.dart';

/// Screen showing detailed info about a single book, including description,
/// tags, reviews, and an option to read or add to cart.
class BookDetailScreen extends ConsumerWidget {
  final String bookId;
  final Map<String, dynamic>? extras;

  const BookDetailScreen({
    Key? key,
    required this.bookId,
    this.extras,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailProvider(bookId));
    final book = bookAsync.value;
    final returnToSearch = extras?['returnToSearch'] == true;

    return WillPopScope(
      onWillPop: () async {
        if (returnToSearch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 150), () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const SearchOverlay(),
              );
            });
          });
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.surface,
            statusBarIconBrightness: Brightness.dark,
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          title: book != null
              ? Text(
                  book.title,
                  style: GoogleFonts.medievalSharp(
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!,
                  ),
                )
              : const Text('Book Detail'),
        ),
        body: bookAsync.when(
          data: (data) {
            if (data == null) {
              return const Center(child: Text('Book not found.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book cover, title, author, rating, categories, meta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.coverImageUrl.isNotEmpty)
                        Hero(
                          tag: 'book-cover-${data.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data.coverImageUrl,
                              height: 180,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                width: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 50),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: GoogleFonts.merriweather(
                                textStyle:
                                    Theme.of(context).textTheme.headlineSmall!,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'by ${data.authors.join(", ")}',
                              style: GoogleFonts.merriweather(
                                textStyle:
                                    Theme.of(context).textTheme.titleMedium!,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  data.averageRating.toStringAsFixed(1),
                                  style: GoogleFonts.merriweather(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleSmall!,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '(${data.categories.join(", ")})',
                                    style: GoogleFonts.merriweather(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Published: ${data.publishedYear} • ${data.pageCount} pages',
                              style: GoogleFonts.merriweather(
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Read Book button
                  LookInsideButton(
                    bookId: data.id,
                    previewUrl: data.pdfUrl,
                    title: data.title,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.medievalSharp(
                      textStyle:
                          Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: GoogleFonts.merriweather(
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Outline-style tags
                  if (data.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: data.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: GoogleFonts.merriweather(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Reviews
                  Text(
                    'Reviews (${data.ratingsCount})',
                    style: GoogleFonts.medievalSharp(
                      textStyle:
                          Theme.of(context).textTheme.titleLarge!,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  ReviewList(bookId: data.id),
                  const SizedBox(height: 16),
                  SubmitReviewForm(bookId: data.id),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load details: $err')),
        ),
        floatingActionButton: book != null
            ? FloatingActionButton.extended(
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
                // show raw PNG icon
                icon: Image.asset(
                  'lib/features/books/assets/cart.png',
                  width: 24,
                  height: 24,
                ),
                label: Text(
                  'Add to Cart',
                  style: GoogleFonts.medievalSharp(
                    textStyle:
                        Theme.of(context).textTheme.titleSmall!
                            .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary,
                            ),
                  ),
                ),
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '\${book.title} added to cart!',
                        style: GoogleFonts.merriweather(
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!,
                        ),
                      ),
                    ),
                  );
                },
              )
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:mobile_app_project_bookstore/features/library/presentation/providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final libraryAsync = ref.watch(userLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'My Library',
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w400, // slightly less bold
          ),
        ),
      ),
      body: libraryAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Your purchased books will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final book = entry.book;

              return Card(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      book.coverImageUrl,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) =>
                          const Icon(Icons.book, size: 50),
                    ),
                  ),
                  // Book title in Merriweather
                  title: Text(
                    book.title,
                    style: GoogleFonts.merriweather(
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Authors in Merriweather
                      Text(
                        book.authors.join(', '),
                        style: GoogleFonts.merriweather(
                          textStyle: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearPercentIndicator(
                              padding: EdgeInsets.zero,
                              percent: entry.readingProgress,
                              lineHeight: 8.0,
                              barRadius: const Radius.circular(4),
                              backgroundColor: Colors.grey[300]!,
                              progressColor:
                                  theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Percentage text in Merriweather
                          Text(
                            "${(entry.readingProgress * 100).toStringAsFixed(0)}%",
                            style: GoogleFonts.merriweather(
                              textStyle: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    context.pushNamed(
                      'bookPreview',
                      pathParameters: {'bookId': book.id},
                      extra: {
                        'url': book.pdfUrl,
                        'title': book.title,
                        'initialPage': entry.lastReadPage,
                        'isFromLibrary': true,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error loading library: $err')),
      ),
    );
  }
}

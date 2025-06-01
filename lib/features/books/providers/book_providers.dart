// lib/features/books/providers/book_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookmatch/features/books/data/repositories/book_repository_impl.dart';
import 'package:bookmatch/features/books/domain/entities/book.dart';
import 'package:bookmatch/features/books/domain/repositories/book_repository.dart';

// Provider for the BookRepository implementation
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl();
});

// Provider to fetch all books
final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.fetchAllBooks();
});

// Provider to fetch a single book by its ID
final bookByIdProvider = FutureProvider.autoDispose.family<Book?, String>((
  ref,
  bookId,
) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.fetchBookById(bookId);
});

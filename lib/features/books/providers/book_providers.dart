// lib/features/books/providers/book_providers.dart

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';

/// How many books to show in each carousel
const int pickCount = 5;

// Provider for the BookRepository implementation
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl();
});

/// Fetch all books
final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.fetchAllBooks();
});

/// Fetch a single book by its ID
final bookByIdProvider =
    FutureProvider.autoDispose.family<Book?, String>((ref, bookId) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.fetchBookById(bookId);
});

/// Randomly pick [pickCount] books for the "Our Top Picks" carousel
final topPicksProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(allBooksProvider.future);
  books.shuffle(Random());
  return books.take(pickCount).toList();
});

/// Randomly pick [pickCount] books for the "Bestsellers" carousel
final bestsellersProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(allBooksProvider.future);
  books.shuffle(Random());
  return books.take(pickCount).toList();
});

final booksByGenreProvider =
FutureProvider.family<List<Book>, String>((ref, genre) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.fetchBooksByGenre(genre);
});



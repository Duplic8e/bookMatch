// lib/features/books/providers/book_providers.dart
// Riverpod providers for managing book detail state.

// lib/features/books/presentation/providers/book_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/datasources/book_firestore_datasource.dart';
import 'package:mobile_app_project_bookstore/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart';

// Datasource Provider
final bookFirestoreDataSourceProvider = Provider<BookFirestoreDataSource>((ref) {
  return BookFirestoreDataSource(FirebaseFirestore.instance);
});

// Repository Provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final dataSource = ref.watch(bookFirestoreDataSourceProvider);
  return BookRepositoryImpl(dataSource);
});

// Provider to fetch a single book by its ID
final bookDetailProvider = FutureProvider.family<Book?, String>((ref, bookId) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getBookById(bookId);
});

// Provider to fetch reviews for a book
final bookReviewsProvider = FutureProvider.family<List<Review>, String>((ref, bookId) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return bookRepository.getBookReviews(bookId);
});

// Provider for submitting a review
// This could also be a method within a StateNotifier if you need to manage submission state (loading, error)
final submitReviewProvider = Provider((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return ({
    required String bookId,
    required Review review,
  }) async {
    await bookRepository.submitReview(bookId, review);
    // Invalidate providers to refetch data after submission
    ref.invalidate(bookReviewsProvider(bookId));
    ref.invalidate(bookDetailProvider(bookId)); // If rating changes, for example
  };
});

// Provider to fetch all books (or a list for the home screen)
final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookRepository = ref.watch(bookRepositoryProvider);
  // You'll need to add a method like 'getAllBooks' or 'getFeaturedBooks' to your BookRepository
  // and its implementation in BookRepositoryImpl and BookFirestoreDataSource
  return bookRepository.getAllBooks(); // Assuming this method exists
});

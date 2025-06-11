import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/data/datasources/book_firestore_datasource.dart';
import 'package:mobile_app_project_bookstore/features/books/data/repositories/book_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for the datasource
final bookFirestoreDataSourceProvider = Provider<BookFirestoreDataSource>((ref) {
  return BookFirestoreDataSource(FirebaseFirestore.instance);
});

// Provider for the repository
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final dataSource = ref.watch(bookFirestoreDataSourceProvider);
  // ** FIX: Correctly pass the dependency to the constructor **
  return BookRepositoryImpl(firestoreDataSource: dataSource);
});

// Provider to get all books
final allBooksProvider = FutureProvider<List<Book>>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getAllBooks();
});

// Provider to get a single book by its ID
final bookDetailProvider = FutureProvider.family<Book?, String>((ref, bookId) {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBookById(bookId);
});

// Provider to get reviews for a specific book
final bookReviewsProvider = FutureProvider.family<List<Review>, String>((ref, bookId) {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBookReviews(bookId);
});

// Provider to submit a review
final submitReviewProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return ({required String bookId, required Review review}) => repository.submitReview(
    bookId: bookId,
    review: review,
  );
});

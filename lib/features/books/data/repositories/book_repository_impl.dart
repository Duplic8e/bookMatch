import 'package:flutter/foundation.dart';
import 'package:mobile_app_project_bookstore/features/books/data/datasources/book_firestore_datasource.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/review_model.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final BookFirestoreDataSource firestoreDataSource;

  BookRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<List<Book>> getAllBooks() async {
    try {
      return await firestoreDataSource.getAllBooks();
    } catch (e) {
      debugPrint('Error in BookRepositoryImpl -> getAllBooks: $e');
      return [];
    }
  }

  @override
  Future<Book?> getBookById(String id) async {
    try {
      return await firestoreDataSource.getBookById(id);
    } catch (e) {
      debugPrint('Error in BookRepositoryImpl -> getBookById: $e');
      return null;
    }
  }

  @override
  Future<List<Review>> getBookReviews(String bookId) async {
    try {
      return await firestoreDataSource.getBookReviews(bookId);
    } catch (e) {
      debugPrint('Error in BookRepositoryImpl -> getBookReviews: $e');
      return [];
    }
  }

  @override
  Future<void> submitReview({required String bookId, required Review review}) async {
    try {
      final reviewModel = ReviewModel(
        id: review.id,
        userId: review.userId,
        userName: review.userName,
        rating: review.rating,
        comment: review.comment,
        timestamp: review.timestamp,
      );
      await firestoreDataSource.submitReview(bookId, reviewModel);
    } catch (e) {
      debugPrint('Error in BookRepositoryImpl -> submitReview: $e');
      rethrow;
    }
  }
}

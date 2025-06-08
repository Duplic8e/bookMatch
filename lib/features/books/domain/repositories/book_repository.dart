// lib/features/books/domain/repositories/book_repository.dart
// The abstract interface for fetching book data.

import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart'; // Assuming you'll create a Review entity

abstract class BookRepository {
  Future<Book?> getBookById(String bookId);
  Future<List<Review>> getBookReviews(String bookId);
  Future<void> submitReview(String bookId, Review review);
  Future<List<Book>> getAllBooks(); // Method signature for fetching all books
  // Add other methods like fetchBooksByCategory, etc.

}
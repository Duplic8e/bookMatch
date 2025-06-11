import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart';

abstract class BookRepository {
  Future<List<Book>> getAllBooks();
  Future<Book?> getBookById(String id);
  Future<List<Review>> getBookReviews(String bookId);

  // ** FIX: Changed to use named parameters to match the implementation **
  Future<void> submitReview({required String bookId, required Review review});
}

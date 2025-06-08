// lib/features/books/data/repositories/book_repository_impl.dart
//Implementation of the BookRepository.

import 'package:mobile_app_project_bookstore/features/books/data/datasources/book_firestore_datasource.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/review.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/review_model.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookFirestoreDataSource _dataSource;

  BookRepositoryImpl(this._dataSource);

  @override
  Future<Book?> getBookById(String bookId) async {
    // The datasource returns BookModel, which is a subtype of Book.
    return _dataSource.getBookById(bookId);
  }

  @override
  Future<List<Review>> getBookReviews(String bookId) async {
    // The datasource returns List<ReviewModel>, convert to List<Review>
    final reviewModels = await _dataSource.getBookReviews(bookId);
    return reviewModels.map((model) => model as Review).toList(); // Simple cast if ReviewModel extends Review
  }

  @override
  Future<void> submitReview(String bookId, Review review) async {
    // Convert Review entity to ReviewModel for the datasource
    final reviewModel = ReviewModel(
      // Assuming ReviewModel has a constructor that takes Review entity fields or a fromEntity factory
      id: review.id, // May not be needed if Firestore generates it
      userId: review.userId,
      rating: review.rating,
      comment: review.comment,
      timestamp: review.timestamp,
      userName: review.userName, // Add this if you denormalize username in reviews
    );
    return _dataSource.submitReview(bookId, reviewModel);
  }

  @override
  Future<List<Book>> getAllBooks() async {
    // The datasource will return a List<BookModel>.
    // Since BookModel extends Book, we can directly return it after fetching.
    // If BookModel didn't extend Book, you'd map from BookModel to Book here.
    final List<BookModel> bookModels = await _dataSource.getAllBooks();
    // This cast works because List<BookModel> is a List<Book> due to inheritance.
    // If you had BookModel.toEntity(), it would be:
    // return bookModels.map((model) => model.toEntity()).toList();
    return bookModels;
  }
}
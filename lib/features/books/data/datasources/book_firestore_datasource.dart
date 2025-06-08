import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/book_model.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/review_model.dart';

class BookFirestoreDataSource {
  final FirebaseFirestore _firestore;

  BookFirestoreDataSource(this._firestore);

  Future<BookModel?> getBookById(String bookId) async {
    final docSnapshot = await _firestore.collection('books').doc(bookId).get();
    if (docSnapshot.exists) {
      return BookModel.fromFirestore(docSnapshot);
    }
    return null;
  }

  Future<List<ReviewModel>> getBookReviews(String bookId) async {
    final querySnapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews') // Assuming 'reviews' is a sub-collection
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
  }

  /// Submits a review and atomically updates the book's average rating.
  Future<void> submitReview(String bookId, ReviewModel review) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    final reviewRef = bookRef.collection('reviews').doc(); // New review document

    return _firestore.runTransaction((transaction) async {
      // 1. Get the current book document
      final bookSnapshot = await transaction.get(bookRef);

      if (!bookSnapshot.exists) {
        throw Exception("Book does not exist!");
      }

      // 2. Calculate the new average rating and count
      final oldRatingCount = bookSnapshot.data()?['ratingsCount'] ?? 0;
      final oldAverageRating = (bookSnapshot.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;

      final newRatingCount = oldRatingCount + 1;
      // Formula to calculate new average: ((old_avg * old_count) + new_rating) / new_count
      final newAverageRating =
          ((oldAverageRating * oldRatingCount) + review.rating) / newRatingCount;

      // 3. Set the new review document in the sub-collection
      transaction.set(reviewRef, review.toFirestore());

      // 4. Update the parent book document with the new rating values
      transaction.update(bookRef, {
        'ratingsCount': newRatingCount,
        'averageRating': newAverageRating,
      });
    });
  }

  Future<List<BookModel>> getAllBooks() async {
    try {
      final querySnapshot = await _firestore
          .collection('books')
          .limit(50) // Limit for performance
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error fetching all books: $e');
      throw Exception('Failed to fetch books from Firestore: $e');
    }
  }
}

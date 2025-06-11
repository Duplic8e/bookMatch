import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
  }

  Future<void> submitReview(String bookId, ReviewModel review) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    final reviewRef = bookRef.collection('reviews').doc();

    return _firestore.runTransaction((transaction) async {
      final bookSnapshot = await transaction.get(bookRef);

      if (!bookSnapshot.exists) {
        throw Exception("Book does not exist!");
      }

      final oldRatingCount = bookSnapshot.data()?['ratingsCount'] ?? 0;
      final oldAverageRating = (bookSnapshot.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;

      final newRatingCount = oldRatingCount + 1;
      final newAverageRating =
          ((oldAverageRating * oldRatingCount) + review.rating) / newRatingCount;

      transaction.set(reviewRef, review.toFirestore());

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
          .limit(50)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch books from Firestore: $e');
      rethrow;
    }
  }
}

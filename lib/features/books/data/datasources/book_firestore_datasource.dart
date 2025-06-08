// lib/features/books/data/datasources/book_firestore_datasource.dart
//mplementation for fetching book data from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/book_model.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/review_model.dart'; // Assuming ReviewModel

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
        .map((doc) => ReviewModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  Future<void> submitReview(String bookId, ReviewModel review) async {
    await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .add(review.toFirestore());
  }

  // **** ENSURE THIS METHOD IS PRESENT AND CORRECT ****
  Future<List<BookModel>> getAllBooks() async {
    try {
      final querySnapshot = await _firestore
          .collection('books')
          // .orderBy('title') // Optional: order by a field
          .limit(20) // Optional: limit the number of books fetched for performance
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Return an empty list if no books are found
      }

      return querySnapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    } catch (e) {
      print('Error fetching all books: $e');
      throw Exception('Failed to fetch books from Firestore: $e');
    }
  }
}
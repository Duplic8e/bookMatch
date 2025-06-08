import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/book_model.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';

class LibraryDataSource {
  final FirebaseFirestore _firestore;

  LibraryDataSource(this._firestore);

  /// Adds a batch of books from the cart to a user's library collection.
  Future<void> addBooksToLibrary(String userId, List<CartItem> items) async {
    final batch = _firestore.batch();
    final libraryCollection = _firestore.collection('users').doc(userId).collection('library');

    for (final item in items) {
      final docRef = libraryCollection.doc(item.book.id);
      batch.set(docRef, {
        'bookId': item.book.id,
        'dateAdded': Timestamp.now(),
        'lastReadPage': 0,
        'readingProgress': 0.0,
        // We can store a reference or the full book data. Storing data simplifies reads.
        'bookData': (item.book as BookModel).toFirestore(),
      });
    }
    await batch.commit();
  }

  /// Fetches all book entries from a user's library.
  Stream<List<BookModel>> getUserLibrary(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // We assume book data is denormalized/stored inside the library entry
        final bookData = doc.data()['bookData'] as Map<String, dynamic>;
        // Re-construct a BookModel from the nested map
        return BookModel(
          id: doc.data()['bookId'],
          title: bookData['title'] ?? 'No Title',
          authors: List<String>.from(bookData['authors'] ?? []),
          description: bookData['description'] ?? '',
          categories: List<String>.from(bookData['categories'] ?? []),
          tags: List<String>.from(bookData['tags'] ?? []),
          publishedYear: bookData['publishedYear'] ?? 0,
          pageCount: bookData['pageCount'] ?? 0,
          coverImageUrl: bookData['coverImageUrl'] ?? '',
          pdfUrl: bookData['pdfUrl'] ?? '',
          averageRating: (bookData['averageRating'] as num?)?.toDouble() ?? 0.0,
          ratingsCount: bookData['ratingsCount'] ?? 0,
        );
      }).toList();
    });
  }
}

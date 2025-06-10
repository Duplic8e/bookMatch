import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/data/models/book_model.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_app_project_bookstore/features/library/data/models/library_entry_model.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';

class LibraryDataSource {
  final FirebaseFirestore _firestore;
  LibraryDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _userLibraryCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('library');
  }

  Future<void> addBooksToLibrary(String userId, List<CartItem> items) async {
    final batch = _firestore.batch();
    final libraryCollection = _userLibraryCollection(userId);

    for (final item in items) {
      final docRef = libraryCollection.doc(item.book.id);
      final bookModel = item.book as BookModel;
      batch.set(docRef, {
        'bookId': item.book.id,
        'dateAdded': Timestamp.now(),
        'lastReadPage': 1,
        'readingProgress': 0.0,
        'bookmarks': [], // Initialize with an empty list
        'bookData': bookModel.toFirestore(),
      });
    }
    await batch.commit();
  }

  Stream<List<LibraryEntryModel>> getUserLibrary(String userId) {
    return _userLibraryCollection(userId)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LibraryEntryModel.fromFirestore(doc, userId)).toList();
    });
  }

  Future<LibraryEntryModel?> getLibraryEntry(String userId, String bookId) async {
    final doc = await _userLibraryCollection(userId).doc(bookId).get();
    if (doc.exists) {
      return LibraryEntryModel.fromFirestore(doc, userId);
    }
    return null;
  }

  Future<void> updateReadingProgress({
    required String userId,
    required String bookId,
    required int pageNumber,
    required int totalPages,
  }) async {
    final progress = totalPages > 0 ? pageNumber / totalPages : 0.0;
    await _userLibraryCollection(userId).doc(bookId).update({
      'lastReadPage': pageNumber,
      'readingProgress': progress.clamp(0.0, 1.0),
    });
  }

  Future<void> addBookmark({
    required String userId,
    required String bookId,
    required Bookmark bookmark,
  }) async {
    await _userLibraryCollection(userId).doc(bookId).update({
      'bookmarks': FieldValue.arrayUnion([bookmark.toMap()]),
    });
  }

  Future<void> removeBookmark({
    required String userId,
    required String bookId,
    required Bookmark bookmark,
  }) async {
    await _userLibraryCollection(userId).doc(bookId).update({
      'bookmarks': FieldValue.arrayRemove([bookmark.toMap()]),
    });
  }
}

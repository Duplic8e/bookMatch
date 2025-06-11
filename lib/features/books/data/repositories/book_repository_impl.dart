import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final FirebaseFirestore firestore;

  BookRepositoryImpl(this.firestore);

  @override
  Future<List<Book>> fetchAllBooks() async {
    final snapshot = await firestore.collection('books').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Book(
        id: doc.id,
        title: data['title'] ?? '',
        author: (data['authors'] as List?)?.first ?? '',
        coverImageUrl: data['coverImageUrl'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        genres: List<String>.from(data['genres'] ?? []),
        tags: List<String>.from(data['tags'] ?? []),
        categories: List<String>.from(data['categories'] ?? []),
      );
    }).toList();
  }

  @override
  Future<Book?> fetchBookById(String id) async {
    final doc = await firestore.collection('books').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: (data['authors'] as List?)?.first ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      genres: List<String>.from(data['genres'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
    );
  }

  @override
  Future<List<Book>> fetchBooksByGenre(String genre) async {
    final snapshot = await firestore
        .collection('books')
        .where('genres', arrayContains: genre)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Book(
        id: doc.id,
        title: data['title'] ?? '',
        author: (data['authors'] as List?)?.first ?? '',
        coverImageUrl: data['coverImageUrl'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        genres: List<String>.from(data['genres'] ?? []),
        tags: List<String>.from(data['tags'] ?? []),
        categories: List<String>.from(data['categories'] ?? []),
      );
    }).toList();
  }
}

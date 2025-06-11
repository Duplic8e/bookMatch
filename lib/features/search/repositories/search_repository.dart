import 'package:cloud_firestore/cloud_firestore.dart';
import '../../books/domain/entities/book.dart';
import '../../books/domain/entities/scored_book.dart';
import '../utils/scoring_utils.dart';

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository(this._firestore);

  Future<List<ScoredBook>> searchBooks(String query, {double? maxPrice}) async {
    final snapshot = await _firestore.collection('books').get();

    final books = snapshot.docs.map((doc) {
      final data = doc.data();
      return Book(
        id: doc.id,
        title: data['title'] ?? '',
        author: (data['authors'] as List?)?.first ?? '', // Firestore uses `authors`
        coverImageUrl: data['coverImageUrl'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        genres: List<String>.from(data['genres'] ?? []),
        tags: List<String>.from(data['tags'] ?? []),
        categories: List<String>.from(data['categories'] ?? []),
      );

    }).toList();

    final results = books.map((book) {
      final score = scoreBook(book, query, maxPrice: maxPrice);
      return ScoredBook(book: book, score: score);
    }).where((sb) => sb.score >= 2).toList();

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

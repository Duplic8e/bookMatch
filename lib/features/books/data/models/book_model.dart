import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.authors,
    required super.description,
    required super.categories,
    required super.tags,
    required super.publishedYear,
    required super.pageCount,
    required super.coverImageUrl,
    required super.pdfUrl,
    required super.averageRating,
    required super.ratingsCount,
  });

  factory BookModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? 'Unknown Title',
      // Safely convert list from Firestore
      authors: List<String>.from(data['authors'] ?? []),
      description: data['description'] ?? 'No description available.',
      categories: List<String>.from(data['categories'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      publishedYear: data['publishedYear'] ?? 0,
      pageCount: data['pageCount'] ?? 0,
      coverImageUrl: data['coverImageUrl'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: data['ratingsCount'] ?? 0,
    );
  }
}

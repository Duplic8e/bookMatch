// This model will be used for Firestore interaction and can include fromJson/toJson methods.

// lib/features/books/data/models/book_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.rating,
    required super.description,
    required super.genre,
    required super.price,
    required super.imageUrl,
    required super.previewUrl,
    required super.format,
    required super.stockStatus,
    required super.sellerDetails,
  });

  factory BookModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? 'Unknown Title',
      author: data['author'] ?? 'Unknown Author',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      genre: data['genre'] ?? 'Uncategorized',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      previewUrl: data['previewUrl'] ?? '',
      format: _bookFormatFromString(data['format']),
      stockStatus: data['stockStatus'] ?? 0,
      sellerDetails: data['sellerDetails'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'rating': rating,
      'description': description,
      'genre': genre,
      'price': price,
      'imageUrl': imageUrl,
      'previewUrl': previewUrl,
      'format': format.name, // Store enum as string
      'stockStatus': stockStatus,
      'sellerDetails': sellerDetails,
    };
  }

  static BookFormat _bookFormatFromString(String? formatString) {
    if (formatString == null) return BookFormat.paperback; // Default
    switch (formatString.toLowerCase()) {
      case 'ebook':
        return BookFormat.ebook;
      case 'paperback':
        return BookFormat.paperback;
      case 'hardcover':
        return BookFormat.hardcover;
      default:
        return BookFormat.paperback;
    }
  }
}
// lib/features/books/domain/entities/book.dart
//This entity will represent the detailed information of a book.

import 'package:flutter/foundation.dart'; // For @immutable

@immutable
class Book {
  final String id;
  final String title;
  final String author;
  final double rating;
  final String description;
  final String genre;
  final double price;
  final String imageUrl; // URL for the book cover
  final String previewUrl; // URL for the "Look Inside" PDF or content
  final BookFormat format;
  final int stockStatus; // e.g., number of items in stock, or a status enum
  final String sellerDetails; // Information about the seller

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.description,
    required this.genre,
    required this.price,
    required this.imageUrl,
    required this.previewUrl,
    required this.format,
    required this.stockStatus,
    required this.sellerDetails,
  });

  // Optional: Add fromJson/toJson if you directly map Firestore docs to this entity
  // For a cleaner separation, this is usually done in the data/models layer.

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum BookFormat {
  ebook,
  paperback,
  hardcover,
}
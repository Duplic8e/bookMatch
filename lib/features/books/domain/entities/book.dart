import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For @immutable

@immutable
class Book extends Equatable {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final double price;
  final List<String> genres;
  final List<String> tags;
  final List<String> categories;
  final int publishedYear;
  final int pageCount;
  final String coverImageUrl;
  final String pdfUrl;
  final double averageRating;
  final int ratingsCount;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description = 'No description available.',
    required this.categories,
    required this.tags,
    required this.publishedYear,
    required this.pageCount,
    required this.coverImageUrl,
    required this.pdfUrl,
    required this.averageRating,
    required this.ratingsCount,
  });

  @override
  List<Object?> get props => [id, title, authors, description, categories, tags, publishedYear, pageCount, coverImageUrl, pdfUrl, averageRating, ratingsCount];
}

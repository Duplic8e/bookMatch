// lib/features/books/domain/entities/book.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String coverImageUrl;
  final String description;
  final double price;
  final List<String> genres;
  final List<String> tags;
  final List<String> categories;


  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    this.description = 'No description available.',
    required this.price,
    this.genres = const [],
    this.tags = const [],
    this.categories = const [],
  });

}
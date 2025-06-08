import 'package:equatable/equatable.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';

class LibraryEntry extends Equatable {
  final String userId;
  final Book book; // We embed the full book object for easy display
  final DateTime dateAdded;
  final int lastReadPage;
  final double readingProgress; // 0.0 to 1.0

  const LibraryEntry({
    required this.userId,
    required this.book,
    required this.dateAdded,
    this.lastReadPage = 0,
    this.readingProgress = 0.0,
  });

  @override
  List<Object?> get props => [userId, book.id];
}

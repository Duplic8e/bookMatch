import 'package:equatable/equatable.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
// ** FIX: Import the new bookmark entity **
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';

class LibraryEntry extends Equatable {
  final String userId;
  final Book book;
  final DateTime dateAdded;
  final int lastReadPage;
  final double readingProgress;
  // ** FIX: Use a List of the Bookmark class **
  final List<Bookmark> bookmarks;

  const LibraryEntry({
    required this.userId,
    required this.book,
    required this.dateAdded,
    this.lastReadPage = 1,
    this.readingProgress = 0.0,
    this.bookmarks = const [],
  });

  @override
  List<Object?> get props => [userId, book.id, bookmarks, lastReadPage, readingProgress];
}

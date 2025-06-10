import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_app_project_bookstore/features/library/data/datasources/library_datasource.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/library_entry.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryDataSource dataSource;

  LibraryRepositoryImpl(this.dataSource);

  @override
  Future<void> addBooksToLibrary(String userId, List<CartItem> items) {
    return dataSource.addBooksToLibrary(userId, items);
  }

  @override
  Stream<List<LibraryEntry>> getUserLibrary(String userId) {
    return dataSource.getUserLibrary(userId);
  }

  @override
  Future<LibraryEntry?> getLibraryEntry(String userId, String bookId) {
    return dataSource.getLibraryEntry(userId, bookId);
  }

  @override
  Future<void> updateReadingProgress({
    required String userId,
    required String bookId,
    required int pageNumber,
    required int totalPages,
  }) {
    return dataSource.updateReadingProgress(
      userId: userId,
      bookId: bookId,
      pageNumber: pageNumber,
      totalPages: totalPages,
    );
  }

  @override
  Future<void> addBookmark({
    required String userId,
    required String bookId,
    required Bookmark bookmark,
  }) {
    return dataSource.addBookmark(
      userId: userId,
      bookId: bookId,
      bookmark: bookmark,
    );
  }

  @override
  Future<void> removeBookmark({
    required String userId,
    required String bookId,
    required Bookmark bookmark,
  }) {
    return dataSource.removeBookmark(
      userId: userId,
      bookId: bookId,
      bookmark: bookmark,
    );
  }
}

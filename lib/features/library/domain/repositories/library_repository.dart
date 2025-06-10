import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/library_entry.dart';

abstract class LibraryRepository {
  Future<void> addBooksToLibrary(String userId, List<CartItem> items);
  Stream<List<LibraryEntry>> getUserLibrary(String userId);
  Future<LibraryEntry?> getLibraryEntry(String userId, String bookId);
  Future<void> updateReadingProgress({
    required String userId,
    required String bookId,
    required int pageNumber,
    required int totalPages,
  });
  Future<void> addBookmark({required String userId, required String bookId, required Bookmark bookmark});
  Future<void> removeBookmark({required String userId, required String bookId, required Bookmark bookmark});
}

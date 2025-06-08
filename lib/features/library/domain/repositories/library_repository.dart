import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';

abstract class LibraryRepository {
  Future<void> addBooksToLibrary(String userId, List<CartItem> items);
  Stream<List<Book>> getUserLibrary(String userId);
}

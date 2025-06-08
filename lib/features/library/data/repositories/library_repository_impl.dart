import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_app_project_bookstore/features/library/data/datasources/library_datasource.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryDataSource dataSource;

  LibraryRepositoryImpl(this.dataSource);

  @override
  Future<void> addBooksToLibrary(String userId, List<CartItem> items) async {
    return dataSource.addBooksToLibrary(userId, items);
  }

  @override
  Stream<List<Book>> getUserLibrary(String userId) {
    return dataSource.getUserLibrary(userId);
  }
}

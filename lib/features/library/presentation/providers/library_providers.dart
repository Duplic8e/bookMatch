import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:mobile_app_project_bookstore/features/library/data/datasources/library_datasource.dart';
// ** FIX: Corrected import path **
import 'package:mobile_app_project_bookstore/features/library/data/repositories/library_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/repositories/library_repository.dart';

// 1. Datasource Provider
final libraryDataSourceProvider = Provider<LibraryDataSource>((ref) {
  return LibraryDataSource(FirebaseFirestore.instance);
});

// 2. Repository Provider
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final dataSource = ref.watch(libraryDataSourceProvider);
  // ** FIX: Correctly instantiate the class with its constructor **
  return LibraryRepositoryImpl(dataSource);
});

// 3. Provider to add books to the library (the "checkout" action)
final addBooksToLibraryProvider = FutureProvider.autoDispose.family<void, List<CartItem>>((ref, items) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider); // from auth_providers
  if (user == null) {
    throw Exception('User must be logged in to add books to the library.');
  }
  await libraryRepository.addBooksToLibrary(user.uid, items);
});

// 4. Provider to stream the user's library
final userLibraryProvider = StreamProvider<List<Book>>((ref) {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return libraryRepository.getUserLibrary(user.uid);
  } else {
    // Return an empty stream if the user is not logged in
    return Stream.value([]);
  }
});

// lib/features/books/domain/repositories/book_repository.dart

import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';

abstract class BookRepository {
  Future<List<Book>> fetchAllBooks();
  Future<List<Book>> fetchBooksByGenre(String genre);
  Future<Book?> fetchBookById(String id);
// Future<List<Book>> searchBooks(String query);
}
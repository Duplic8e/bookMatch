// lib/features/books/data/repositories/book_repository_impl.dart

import 'package:bookmatch/features/books/domain/entities/book.dart';
import 'package:bookmatch/features/books/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final List<Book> _mockBooks = [
    Book(
      id: '1',
      title: 'The Great Flutterby',
      author: 'Dev Eloper',
      coverImageUrl: 'https://picsum.photos/seed/book1/200/300',
      description: 'A thrilling adventure in the world of widgets.',
      price: 19.99,
      genres: ['Tech', 'Fiction'],
    ),
    Book(
      id: '2',
      title: 'Riverpod State Management',
      author: 'R. Iver Pod',
      coverImageUrl: 'https://picsum.photos/seed/book2/200/300',
      description: 'Master the art of state management in Flutter.',
      price: 29.99,
      genres: ['Tech', 'Education'],
    ),
    Book(
      id: '3',
      title: 'Dart for Beginners',
      author: 'A. Programmer',
      coverImageUrl: 'https://picsum.photos/seed/book3/200/300',
      description: 'Learn the fundamentals of the Dart programming language.',
      price: 15.00,
      genres: ['Tech', 'Education'],
    ),
    Book(
      id: '4',
      title: 'Mystery of the Missing Semicolon',
      author: 'Syntax Errorian',
      coverImageUrl: 'https://picsum.photos/seed/book4/200/300',
      description: 'A classic coding whodunit.',
      price: 12.50,
      genres: ['Mystery', 'Tech'],
    ),
  ];

  @override
  Future<List<Book>> fetchAllBooks() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockBooks;
  }

  @override
  Future<Book?> fetchBookById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockBooks.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Book>> fetchBooksByGenre(String genre) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBooks.where((book) => book.genres.contains(genre)).toList();
  }
}

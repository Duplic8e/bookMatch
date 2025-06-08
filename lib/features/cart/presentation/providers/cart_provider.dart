import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:mobile_app_project_bookstore/features/cart/domain/entities/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Book book) {
    // Check if the book is already in the cart to prevent duplicates
    final isAlreadyInCart = state.any((item) => item.book.id == book.id);
    if (!isAlreadyInCart) {
      state = [...state, CartItem(book: book)];
    }
    // If you add quantity later, you would increment it here instead.
  }

  void removeFromCart(String bookId) {
    state = state.where((item) => item.book.id != bookId).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

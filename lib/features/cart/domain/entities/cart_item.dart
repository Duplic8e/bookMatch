import 'package:equatable/equatable.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';

class CartItem extends Equatable {
  final Book book;
  // In a real app, you might add a 'quantity' field here
  // final int quantity;

  const CartItem({required this.book});

  @override
  List<Object> get props => [book.id];
}

// lib/features/books/domain/entities/review.dart
import 'package:flutter/foundation.dart';

@immutable
class Review {
  final String id; // Firestore document ID
  final String userId;
  final String userName; // Denormalized for easier display
  final double rating; // e.g., 1.0 to 5.0
  final String comment;
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Review &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
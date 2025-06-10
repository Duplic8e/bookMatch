import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  final int pageNumber;
  final String label;

  const Bookmark({required this.pageNumber, required this.label});

  @override
  List<Object?> get props => [pageNumber, label];

  // Helper method to convert to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'pageNumber': pageNumber,
      'label': label,
    };
  }

  // Helper method to create from a Map from Firestore
  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      pageNumber: map['pageNumber'] as int,
      label: map['label'] as String,
    );
  }
}

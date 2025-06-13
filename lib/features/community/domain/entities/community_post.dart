import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final List<String> likedBy;
  // ** NEW: Add comment count **
  final int commentCount;
  final Map<String, dynamic>? bookCitation;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    required this.likedBy,
    required this.commentCount,
    this.bookCitation,
  });

  @override
  List<Object?> get props => [id, authorId, text, createdAt, likedBy.length, commentCount];
}

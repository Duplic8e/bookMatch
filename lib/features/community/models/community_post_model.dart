import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';

class CommunityPostModel extends CommunityPost {
  const CommunityPostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.text,
    required super.createdAt,
    required super.likedBy,
    required super.commentCount,
    super.bookCitation,
  });

  factory CommunityPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      // ** NEW: Read the comment count, default to 0 **
      commentCount: data['commentCount'] ?? 0,
      bookCitation: data['bookCitation'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      // ** NEW: Initialize comment count when creating a post **
      'commentCount': commentCount,
      'bookCitation': bookCitation,
    };
  }
}

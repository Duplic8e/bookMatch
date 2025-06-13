import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';

abstract class CommunityPostRepository {
  Future<List<CommunityPost>> getPosts({DocumentSnapshot? lastDoc, int limit = 10});
  Future<void> addPost(CommunityPost post);
  Future<void> deletePost(String postId);
  Future<void> togglePostLike({required String postId, required String userId});
}

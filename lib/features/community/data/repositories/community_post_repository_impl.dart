import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/community/data/datasources/firestore_community_post_datasource.dart';
import 'package:mobile_app_project_bookstore/features/community/models/community_post_model.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/repositories/community_post_repository.dart';

class CommunityPostRepositoryImpl implements CommunityPostRepository {
  final FirestoreCommunityPostDataSource datasource;

  CommunityPostRepositoryImpl({required this.datasource});

  @override
  Future<void> addPost(CommunityPost post) {
    final model = CommunityPostModel(
      id: post.id,
      authorId: post.authorId,
      authorName: post.authorName,
      text: post.text,
      createdAt: post.createdAt,
      likedBy: post.likedBy,
      bookCitation: post.bookCitation,
      // ** THE FIX: Pass the comment count to the model **
      commentCount: post.commentCount,
    );
    return datasource.addPost(model);
  }

  @override
  Future<void> deletePost(String postId) {
    return datasource.deletePost(postId);
  }

  @override
  Future<List<CommunityPost>> getPosts({DocumentSnapshot? lastDoc, int limit = 10}) async {
    final docSnapshots = await datasource.getPosts(lastDoc: lastDoc, limit: limit);
    return docSnapshots.map((doc) => CommunityPostModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> togglePostLike({required String postId, required String userId}) {
    return datasource.togglePostLike(postId: postId, userId: userId);
  }
}

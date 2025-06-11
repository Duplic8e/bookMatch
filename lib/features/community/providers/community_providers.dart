import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/data/datasources/firestore_community_post_datasource.dart';
import 'package:mobile_app_project_bookstore/features/community/data/repositories/community_post_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/repositories/community_post_repository.dart';

// --- DATA LAYER PROVIDERS ---
final firestoreCommunityPostDatasourceProvider = Provider((ref) {
  return FirestoreCommunityPostDataSource();
});

final communityPostRepositoryProvider = Provider<CommunityPostRepository>((ref) {
  final datasource = ref.watch(firestoreCommunityPostDatasourceProvider);
  return CommunityPostRepositoryImpl(datasource: datasource);
});


// --- STATE NOTIFIER PROVIDER ---
final communityControllerProvider = StateNotifierProvider.autoDispose<CommunityController, AsyncValue<CommunityFeedState>>((ref) {
  final repository = ref.watch(communityPostRepositoryProvider);
  return CommunityController(repository, ref);
});


class CommunityFeedState {
  final List<CommunityPost> posts;
  final bool isLoadingNextPage;
  final bool hasMore;

  CommunityFeedState({
    this.posts = const [],
    this.isLoadingNextPage = false,
    this.hasMore = true,
  });

  CommunityFeedState copyWith({
    List<CommunityPost>? posts,
    bool? isLoadingNextPage,
    bool? hasMore,
  }) {
    return CommunityFeedState(
      posts: posts ?? this.posts,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CommunityController extends StateNotifier<AsyncValue<CommunityFeedState>> {
  final CommunityPostRepository _repository;
  final Ref _ref;
  final int _limit = 10;

  String? get _currentUserId => _ref.read(authStateChangesProvider).value?.uid;

  CommunityController(this._repository, this._ref) : super(const AsyncLoading()) {
    fetchInitialPosts();
  }

  Future<void> fetchInitialPosts() async {
    state = const AsyncLoading();
    try {
      final posts = await _repository.getPosts(limit: _limit);
      state = AsyncData(CommunityFeedState(
        posts: posts,
        hasMore: posts.length == _limit,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> fetchNextPage() async {
    if (state.value?.isLoadingNextPage == true || state.value?.hasMore == false) return;

    state = AsyncData(state.value!.copyWith(isLoadingNextPage: true));

    final lastPostId = state.value!.posts.last.id;
    final lastDoc = await FirebaseFirestore.instance.collection('posts').doc(lastPostId).get();

    try {
      final newPosts = await _repository.getPosts(lastDoc: lastDoc, limit: _limit);
      state = AsyncData(state.value!.copyWith(
        posts: [...state.value!.posts, ...newPosts],
        hasMore: newPosts.length == _limit,
        isLoadingNextPage: false,
      ));
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isLoadingNextPage: false));
    }
  }

  Future<void> addPost({required String text, required String authorName, Map<String, dynamic>? bookCitation}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception("User not logged in");

    final post = CommunityPost(
      id: '',
      authorId: userId,
      authorName: authorName,
      text: text,
      createdAt: DateTime.now(),
      likedBy: [],
      bookCitation: bookCitation,
      // ** THE FIX: Initialize new posts with a comment count of 0 **
      commentCount: 0,
    );
    await _repository.addPost(post);
    await fetchInitialPosts();
  }

  Future<void> togglePostLike(String postId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final currentPosts = state.valueOrNull?.posts ?? [];
    final updatedPosts = currentPosts.map((post) {
      if (post.id == postId) {
        final newLikedBy = List<String>.from(post.likedBy);
        if (newLikedBy.contains(userId)) {
          newLikedBy.remove(userId);
        } else {
          newLikedBy.add(userId);
        }
        return CommunityPost(id: post.id, authorId: post.authorId, authorName: post.authorName, text: post.text, createdAt: post.createdAt, likedBy: newLikedBy, bookCitation: post.bookCitation, commentCount: post.commentCount);
      }
      return post;
    }).toList();
    state = AsyncData(state.value!.copyWith(posts: updatedPosts));

    try {
      await _repository.togglePostLike(postId: postId, userId: userId);
    } catch (e) {
      state = AsyncData(state.value!.copyWith(posts: currentPosts));
    }
  }

  Future<void> deletePost(String postId) async {
    final currentPosts = state.valueOrNull?.posts ?? [];
    state = AsyncData(state.value!.copyWith(posts: currentPosts.where((p) => p.id != postId).toList()));

    try {
      await _repository.deletePost(postId);
    } catch (e) {
      state = AsyncData(state.value!.copyWith(posts: currentPosts));
    }
  }
}

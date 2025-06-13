import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/community_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/widgets/comment_input_field.dart';
import 'package:mobile_app_project_bookstore/features/community/widgets/comment_list.dart';
import 'package:mobile_app_project_bookstore/features/community/widgets/post_card.dart';

class PostDetailsScreen extends ConsumerWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the main feed state to find our specific post
    final feedStateAsync = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                feedStateAsync.when(
                  data: (feedState) {
                    // ** THE FIX: Use a safer method to find the post **
                    final List<CommunityPost> matchingPosts = feedState.posts.where((p) => p.id == postId).toList();

                    if (matchingPosts.isEmpty) {
                      return const SliverFillRemaining(child: Center(child: Text('Post not found or has been deleted.')));
                    }

                    final post = matchingPosts.first;

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Display the original post card at the top
                        PostCard(post: post),
                        const Divider(height: 1),
                        // Display the list of comments below it
                        CommentList(postId: postId),
                      ]),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                  error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
                ),
              ],
            ),
          ),
          // Input field is pinned to the bottom
          CommentInputField(postId: postId),
        ],
      ),
    );
  }
}

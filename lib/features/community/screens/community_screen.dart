import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/community_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/widgets/post_card.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(communityControllerProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedStateAsync = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: feedStateAsync.when(
        data: (feedState) {
          if (feedState.posts.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first!'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(communityControllerProvider.notifier).fetchInitialPosts(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: feedState.posts.length + (feedState.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < feedState.posts.length) {
                  final post = feedState.posts[index];
                  return PostCard(post: post);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading posts: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('createPost');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/community_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? bookCitation;

  const CreatePostScreen({super.key, this.bookCitation});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isPosting = true);

      final user = ref.read(authStateChangesProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to post.')));
        setState(() => _isPosting = false);
        return;
      }

      try {
        // ** THE FIX: Call the addPost method with the correct parameters **
        await ref.read(communityControllerProvider.notifier).addPost(
          text: _textController.text.trim(),
          authorName: user.displayName ?? 'Anonymous User',
          bookCitation: widget.bookCitation,
        );

        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create post: ${e.toString()}')));
        }
      } finally {
        if (mounted) setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
        actions: [
          if (_isPosting)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator())),
            )
          else
            TextButton(
              onPressed: _submitPost,
              child: const Text('POST'),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.bookCitation != null)
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Sharing a thought from "${widget.bookCitation!['title']}" (Page ${widget.bookCitation!['pageNumber']})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                maxLines: 8,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Post cannot be empty.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

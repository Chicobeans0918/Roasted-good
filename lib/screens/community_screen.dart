import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/community_post.dart';
import '../services/community_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_widgets.dart';

/// Community: a minimalist forum for brew notes, tastings,
/// questions and coffee chat. Backed by the shared `posts`
/// Firestore collection; works offline via best-effort sync.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = AppState.of(context);
    // Firebase isn't initialized in widget tests / offline previews —
    // fall back to a quiet empty state instead of crashing.
    CommunityService? service;
    try {
      service = CommunityService(FirebaseFirestore.instance);
    } catch (_) {
      service = null;
    }
    final svc = service;

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: svc == null || state.uid == null
          ? null
          : FloatingActionButton(
              tooltip: 'New post',
              backgroundColor: p.ink,
              foregroundColor: p.onIdentityCard,
              onPressed: () => _showComposeSheet(context, svc, state),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: svc == null
            ? ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                children: const [
                  SizedBox(height: 32),
                  EmptyState(
                    icon: Icons.forum_outlined,
                    headline: 'Community is offline',
                    body:
                        'Check your connection — the conversation will be here when you are back.',
                  ),
                ],
              )
            : StreamBuilder<List<CommunityPost>>(
                stream: svc.watchPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                children: [
                  const SizedBox(height: 32),
                  EmptyState(
                    icon: Icons.forum_outlined,
                    headline: 'No posts yet',
                    body:
                        'Share a brewing note, a tasting, or ask the community — be the first to post.',
                    ctaLabel: state.uid == null
                        ? 'Sign in to post'
                        : 'Write a post',
                    onCta: () => state.uid == null
                        ? null
                        : _showComposeSheet(context, svc, state),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _PostCard(
                post: posts[index],
                service: svc,
                uid: state.uid,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showComposeSheet(
    BuildContext context,
    CommunityService service,
    AppState state,
  ) {
    final uid = state.uid;
    if (uid == null) return;
    final name =
        state.userName.isEmpty ? 'Coffee lover' : state.userName;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 32,
        ),
        child: _ComposeForm(
          onPost: (kind, body) async {
            final ok = await service.createPost(
              userId: uid,
              userName: name,
              kind: kind,
              body: body,
            );
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Could not post right now — check your connection.'),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.service,
    required this.uid,
  });

  final CommunityPost post;
  final CommunityService service;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final liked = post.likedByUser(uid);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  communityKindLabels[post.kind] ?? 'Chat',
                  style: theme.textTheme.labelSmall,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${post.userName} · ${_timeAgo(post.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: uid == null
                    ? null
                    : () => service.toggleLike(post, uid!),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: liked ? Colors.redAccent : p.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposeForm extends StatefulWidget {
  const _ComposeForm({required this.onPost});

  final Future<void> Function(String kind, String body) onPost;

  @override
  State<_ComposeForm> createState() => _ComposeFormState();
}

class _ComposeFormState extends State<_ComposeForm> {
  String _kind = 'brewing';
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: p.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('New post', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final entry in communityKindLabels.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: _kind == entry.key,
                showCheckmark: false,
                onSelected: (_) =>
                    setState(() => _kind = entry.key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 5,
          minLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText:
                'What are you brewing? Share a tasting, ask a question…',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _controller.text.trim().isEmpty || _posting
                ? null
                : () async {
                    setState(() => _posting = true);
                    await widget.onPost(
                        _kind, _controller.text.trim());
                  },
            child: _posting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ),
      ],
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.month}/${date.day}/${date.year}';
}

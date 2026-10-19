import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/post_comment.dart';
import '../services/community_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Community leaderboard, ranked by points.
/// 10 per post · 2 per like given · 5 per comment written.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    CommunityService? service;
    try {
      service = CommunityService(FirebaseFirestore.instance);
    } catch (_) {
      service = null;
    }
    final svc = service;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: svc == null
            ? Center(
                child: Text(
                  'Leaderboard is offline right now.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.muted,
                  ),
                ),
              )
            : StreamBuilder<List<LeaderboardEntry>>(
                stream: svc.watchLeaderboard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  final entries = snapshot.data ?? [];
                  if (entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(32),
                        child: Text(
                          'No points yet.\nPost, like and comment to climb the board.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: p.muted),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            24, 12, 24, 4),
                        child: Text(
                          '10 PTS PER POST · 2 PTS PER LIKE · 5 PTS PER COMMENT',
                          textAlign: TextAlign.center,
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                            color: p.muted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              24, 12, 24, 48),
                          itemCount: entries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final isMe =
                                entry.userId == state.uid;
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? p.ink.withValues(alpha: 0.08)
                                    : null,
                                border: Border.all(
                                  color: isMe ? p.ink : p.line,
                                  width: isMe ? 1.5 : 1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      _rankLabel(index),
                                      textAlign: TextAlign.center,
                                      style: theme
                                          .textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: index < 3
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.userName +
                                              (isMe ? ' (you)' : ''),
                                          style: theme.textTheme
                                              .titleSmall,
                                        ),
                                        Text(
                                          '${entry.postCount} posts · '
                                          '${entry.likeCount} likes · '
                                          '${entry.commentCount} comments',
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                            color: p.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${entry.points}',
                                    style: theme
                                        .textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  String _rankLabel(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}';
    }
  }
}

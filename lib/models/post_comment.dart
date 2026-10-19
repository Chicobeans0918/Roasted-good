import 'package:cloud_firestore/cloud_firestore.dart';

/// A comment on a community post.
/// Lives in `posts/{postId}/comments`.
class PostComment {
  const PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String body;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PostComment.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['createdAt'];
    return PostComment(
      id: id,
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? 'Coffee lover') as String,
      body: (map['body'] ?? '') as String,
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// A leaderboard entry: `leaderboard/{uid}`.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.points,
    required this.postCount,
    required this.likeCount,
    required this.commentCount,
  });

  final String userId;
  final String userName;
  final int points;
  final int postCount;
  final int likeCount;
  final int commentCount;

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String id) {
    return LeaderboardEntry(
      userId: id,
      userName: (map['userName'] ?? 'Coffee lover') as String,
      points: (map['points'] ?? 0) as int,
      postCount: (map['postCount'] ?? 0) as int,
      likeCount: (map['likeCount'] ?? 0) as int,
      commentCount: (map['commentCount'] ?? 0) as int,
    );
  }
}

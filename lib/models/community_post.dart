import 'package:cloud_firestore/cloud_firestore.dart';

/// A community forum post: a brewing note, tasting share, question,
/// or general coffee chat. Lives in the shared `posts` collection.
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.imageUrl,
    this.likeCount = 0,
    this.likedBy = const [],
    this.commentCount = 0,
  });

  final String id;
  final String userId;
  final String userName;

  /// 'brewing', 'tasting', 'question' or 'chat'.
  final String kind;
  final String body;
  final DateTime createdAt;

  /// Firebase Storage download URL, null when the post has no photo.
  final String? imageUrl;
  final int likeCount;
  final List<String> likedBy;

  /// Denormalized comment count, maintained by the service.
  final int commentCount;

  bool likedByUser(String? uid) => uid != null && likedBy.contains(uid);

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'kind': kind,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'likeCount': likeCount,
        'likedBy': likedBy,
        'commentCount': commentCount,
      };

  factory CommunityPost.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['createdAt'];
    return CommunityPost(
      id: id,
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? 'Coffee lover') as String,
      kind: (map['kind'] ?? 'chat') as String,
      body: (map['body'] ?? '') as String,
      imageUrl: map['imageUrl'] as String?,
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      likeCount: (map['likeCount'] ?? 0) as int,
      likedBy: [
        for (final u in (map['likedBy'] as List? ?? [])) u as String,
      ],
      commentCount: (map['commentCount'] ?? 0) as int,
    );
  }
}

/// Display labels for post kinds.
const communityKindLabels = {
  'brewing': 'Brewing',
  'tasting': 'Tasting',
  'question': 'Question',
  'chat': 'Chat',
};

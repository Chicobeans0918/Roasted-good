import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_post.dart';

/// Best-effort Firestore backend for the community forum.
/// Reads are a live stream; writes swallow errors so offline
/// never breaks the app.
class CommunityService {
  CommunityService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  /// Live feed, newest first.
  Stream<List<CommunityPost>> watchPosts({int limit = 50}) {
    try {
      return _posts
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => [
                for (final doc in snap.docs)
                  CommunityPost.fromMap(doc.data(), doc.id),
              ]);
    } catch (_) {
      return Stream.value(const []);
    }
  }

  Future<bool> createPost({
    required String userId,
    required String userName,
    required String kind,
    required String body,
  }) async {
    try {
      await _posts.add(CommunityPost(
        id: '',
        userId: userId,
        userName: userName,
        kind: kind,
        body: body.trim(),
        createdAt: DateTime.now(),
      ).toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Toggles the user's like. Returns false when offline.
  Future<bool> toggleLike(CommunityPost post, String uid) async {
    try {
      final ref = _posts.doc(post.id);
      final liked = post.likedBy.contains(uid);
      await ref.update({
        'likedBy': liked
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid]),
        'likeCount': FieldValue.increment(liked ? -1 : 1),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

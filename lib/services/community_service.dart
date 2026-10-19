import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/community_post.dart';
import '../models/post_comment.dart';

/// Point values for the community leaderboard.
abstract final class CommunityPoints {
  static const perPost = 10;
  static const perLike = 2;
  static const perComment = 5;
}

/// Best-effort Firestore + Storage backend for the community forum.
/// Reads are a live stream; writes swallow errors so offline
/// never breaks the app.
class CommunityService {
  CommunityService(this._db, [FirebaseStorage? storage])
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  CollectionReference<Map<String, dynamic>> _comments(String postId) =>
      _posts.doc(postId).collection('comments');

  DocumentReference<Map<String, dynamic>> _rank(String uid) =>
      _db.collection('leaderboard').doc(uid);

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
    XFile? image,
  }) async {
    try {
      final doc = _posts.doc();
      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadImage(doc.id, image);
        if (imageUrl == null) return false;
      }
      await doc.set(CommunityPost(
        id: '',
        userId: userId,
        userName: userName,
        kind: kind,
        body: body.trim(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      ).toMap());
      await _awardPoints(
        uid: userId,
        userName: userName,
        points: CommunityPoints.perPost,
        postDelta: 1,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Uploads a post photo to `posts/<postId>.jpg`.
  /// Returns the download URL, or null when the upload fails.
  Future<String?> _uploadImage(String postId, XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final ref = _storage.ref('posts/$postId.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  /// Toggles the user's like. Returns false when offline.
  /// Liking earns the liker [CommunityPoints.perLike] points;
  /// unliking takes them back.
  Future<bool> toggleLike(CommunityPost post, String uid,
      {String userName = 'Coffee lover'}) async {
    try {
      final ref = _posts.doc(post.id);
      final liked = post.likedBy.contains(uid);
      await ref.update({
        'likedBy': liked
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid]),
        'likeCount': FieldValue.increment(liked ? -1 : 1),
      });
      await _awardPoints(
        uid: uid,
        userName: userName,
        points: liked
            ? -CommunityPoints.perLike
            : CommunityPoints.perLike,
        likeDelta: liked ? -1 : 1,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Live comments for a post, newest first.
  Stream<List<PostComment>> watchComments(String postId,
      {int limit = 50}) {
    try {
      return _comments(postId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => [
                for (final doc in snap.docs)
                  PostComment.fromMap(doc.data(), doc.id),
              ]);
    } catch (_) {
      return Stream.value(const []);
    }
  }

  /// Adds a comment and awards the commenter
  /// [CommunityPoints.perComment] points.
  Future<bool> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String body,
  }) async {
    try {
      await _comments(postId).add(PostComment(
        id: '',
        userId: userId,
        userName: userName,
        body: body.trim(),
        createdAt: DateTime.now(),
      ).toMap());
      await _posts.doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
      await _awardPoints(
        uid: userId,
        userName: userName,
        points: CommunityPoints.perComment,
        commentDelta: 1,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Live leaderboard, highest points first.
  Stream<List<LeaderboardEntry>> watchLeaderboard(
      {int limit = 50}) {
    try {
      return _db
          .collection('leaderboard')
          .orderBy('points', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => [
                for (final doc in snap.docs)
                  LeaderboardEntry.fromMap(doc.data(), doc.id),
              ]);
    } catch (_) {
      return Stream.value(const []);
    }
  }

  /// Adds points to the user's own leaderboard entry.
  /// Best-effort: failures never surface to the UI.
  Future<void> _awardPoints({
    required String uid,
    required String userName,
    required int points,
    int postDelta = 0,
    int likeDelta = 0,
    int commentDelta = 0,
  }) async {
    try {
      await _rank(uid).set(
        {
          'userName': userName,
          'points': FieldValue.increment(points),
          'postCount': FieldValue.increment(postDelta),
          'likeCount': FieldValue.increment(likeDelta),
          'commentCount': FieldValue.increment(commentDelta),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}

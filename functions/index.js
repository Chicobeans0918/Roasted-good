/**
 * Roasted push notifications (Firebase Cloud Functions, 2nd gen).
 *
 * Triggers:
 * - onCommentCreated: someone comments on your post  -> notify post author
 * - onCommentReplyCreated: someone replies to your comment -> notify parent comment author
 * - onPostLiked:      someone likes your post        -> notify post author
 *
 * Device tokens live at users/{uid}/private/fcm (written by the app's
 * NotificationService). Self-actions never notify.
 *
 * Deploy: firebase deploy --only functions
 * (requires the Blaze pay-as-you-go plan; free tier is generous)
 */
const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();

async function tokenFor(uid) {
  const snap = await db.collection('users').doc(uid)
      .collection('private').doc('fcm').get();
  return snap.exists ? snap.data().token : null;
}

async function notifyUser(uid, title, body, data = {}) {
  const token = await tokenFor(uid);
  if (!token) return;
  try {
    await getMessaging().send({token,
      notification: {title, body},
      data: {...data, click_action: 'FLUTTER_NOTIFICATION_CLICK'},
      apns: {payload: {aps: {sound: 'default'}}},
    });
  } catch (e) {
    // Stale token — drop it so future sends don't keep failing.
    if (e.code === 'messaging/registration-token-not-registered') {
      await db.collection('users').doc(uid)
          .collection('private').doc('fcm').delete();
    }
  }
}

exports.onCommentCreated = onDocumentCreated(
    'posts/{postId}/comments/{commentId}',
    async (event) => {
      const comment = event.data.data();
      const {postId} = event.params;
      const postSnap = await db.collection('posts').doc(postId).get();
      if (!postSnap.exists) return;
      const post = postSnap.data();
      // Don't notify when the author comments on their own post.
      if (!post.userId || post.userId === comment.userId) return;
      await notifyUser(
          post.userId,
          'New comment on your post',
          `${comment.userName || 'Someone'}: ${comment.body || ''}`.slice(0, 120),
          {type: 'comment', postId},
      );
    });

// A reply is also a comment, so onCommentCreated already notifies the
// post author. This trigger covers the other person in the thread: the
// author of the comment being replied to. Skipped when that person is
// the post author (already notified) or the replier themselves.
exports.onCommentReplyCreated = onDocumentCreated(
    'posts/{postId}/comments/{commentId}',
    async (event) => {
      const comment = event.data.data();
      const {postId} = event.params;
      const parentId = comment.parentCommentId;
      if (!parentId) return; // top-level comment, not a reply
      const parentSnap = await db.collection('posts').doc(postId)
          .collection('comments').doc(parentId).get();
      if (!parentSnap.exists) return;
      const parent = parentSnap.data();
      if (!parent.userId || parent.userId === comment.userId) return;
      const postSnap = await db.collection('posts').doc(postId).get();
      if (postSnap.exists && postSnap.data().userId === parent.userId) return;
      await notifyUser(
          parent.userId,
          'New reply to your comment',
          `${comment.userName || 'Someone'}: ${comment.body || ''}`.slice(0, 120),
          {type: 'reply', postId, commentId: parentId},
      );
    });

exports.onPostLiked = onDocumentUpdated(
    'posts/{postId}',
    async (event) => {
      const before = event.data.before.data().likedBy || [];
      const after = event.data.after.data().likedBy || [];
      if (after.length <= before.length) return; // unlike or no change
      const newLiker = after.find((uid) => !before.includes(uid));
      const post = event.data.after.data();
      if (!newLiker || !post.userId || newLiker === post.userId) return;
      await notifyUser(
          post.userId,
          'Someone liked your post',
          'Your post got some love in the Community.',
          {type: 'like', postId: event.params.postId},
      );
    });

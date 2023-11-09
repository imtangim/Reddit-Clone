import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Constant/firebase_constant.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/typedef.dart';
import 'package:reddit_clone/models/comment.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';

final postRepositoryProvider = Provider(
  (ref) => PostReporsitory(
      firestore: ref.watch(fireStoreProvider),
      storage: ref.read(storageProvider)),
);

class PostReporsitory {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PostReporsitory(
      {required FirebaseFirestore firestore, required FirebaseStorage storage})
      : _firestore = firestore,
        _storage = storage;

  CollectionReference get _post =>
      _firestore.collection(FirebaseConstant.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstant.commentsCollection);
  CollectionReference get _user =>
      _firestore.collection(FirebaseConstant.usersCollection);

  Futurevoid addPost(Post post) async {
    try {
      return right(_post.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _post
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createPost', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _post
        .orderBy('createPost', descending: true)
        .limit(3)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Futurevoid deletePhoto(Post post) async {
    try {
      return right(
        _storage
            .ref()
            .child("post")
            .child(post.communityName)
            .child(post.id)
            .delete(),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Futurevoid deletePost(Post post) async {
    try {
      return right(
        _post.doc(post.id).delete(),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upVote(Post post, String uid) async {
    if (post.downvotes.contains(uid)) {
      _post.doc(post.id).update({
        "downvotes": FieldValue.arrayRemove([uid])
      });
    }
    if (post.upvotes.contains(uid)) {
      _post.doc(post.id).update({
        "upvotes": FieldValue.arrayRemove([uid])
      });
    } else {
      _post.doc(post.id).update({
        "upvotes": FieldValue.arrayUnion([uid])
      });
    }
  }

  void downVote(Post post, String uid) async {
    if (post.upvotes.contains(uid)) {
      _post.doc(post.id).update({
        "upvotes": FieldValue.arrayRemove([uid])
      });
    }
    if (post.downvotes.contains(uid)) {
      _post.doc(post.id).update({
        "downvotes": FieldValue.arrayRemove([uid])
      });
    } else {
      _post.doc(post.id).update({
        "downvotes": FieldValue.arrayUnion([uid])
      });
    }
  }

  Stream<Post> getPostByID(String postid) {
    return _post
        .doc(postid)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  Futurevoid addComment(Comments comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_post.doc(comment.postID).update({
        "commentCount": FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comments>> getAllComments(String postid) {
    return _comments
        .where('postID', isEqualTo: postid)
        .orderBy('createAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comments.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Futurevoid awardPost(Post post, String award, String senderID) async {
    try {
      _post.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award])
      });
      _user.doc(senderID).update({
        'awards': FieldValue.arrayRemove([award])
      });

      return right(_user.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

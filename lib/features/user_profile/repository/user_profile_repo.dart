import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Constant/firebase_constant.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/typedef.dart';
import 'package:reddit_clone/models/post_model.dart';

import 'package:reddit_clone/models/user_model.dart';

final userProfileRepositoryProvider = Provider(
  (ref) => UserProfileRepository(firestore: ref.watch(fireStoreProvider)),
);

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstant.usersCollection);
  CollectionReference get _post =>
      _firestore.collection(FirebaseConstant.postsCollection);

  Futurevoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _post
        .where("uid", isEqualTo: uid)
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

  Futurevoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karma': user.karma,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<UserModel>> searchUser(String query) {
    return _users
        .where(
          "name",
          isLessThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<UserModel> users= [];
      for (var community in event.docs) {
        users.add(
          UserModel.fromMap(community.data() as Map<String, dynamic>),
        );
      }
      return users;
    });
  }
}

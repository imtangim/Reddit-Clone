import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Constant/firebase_constant.dart';

import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/typedef.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';

final communityRepositoryProvider = Provider(
  (ref) => CommunityRepository(firestore: ref.watch(fireStoreProvider)),
);

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstant.communitiesCollection);

  CollectionReference get _post =>
      _firestore.collection(FirebaseConstant.postsCollection);

  Futurevoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw "Community with the same name already exits";
      }
      return right(
        await _communities.doc(community.name).set(community.toMap()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Futurevoid joinCommunity(String name, String userID) async {
    try {
      return right(
        _communities.doc(name).update(
          {
            "members": FieldValue.arrayUnion([userID])
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Futurevoid leaveCommunity(String name, String userID) async {
    try {
      return right(
        _communities.doc(name).update(
          {
            "members": FieldValue.arrayRemove([userID])
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunity(String uid) {
    return _communities
        .where("members", arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var element in event.docs) {
        communities.add(
          Community.fromMap(element.data() as Map<String, dynamic>),
        );
      }
      return communities;
    });
  }

  // Stream<Community> getCommunityByName(String name) {
  //   return _communities.doc(name).snapshots().map(
  //       (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  // }
  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) {
      // print(event.data());
      return Community.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
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
      List<Community> communities = [];
      for (var community in event.docs) {
        communities.add(
          Community.fromMap(community.data() as Map<String, dynamic>),
        );
      }
      return communities;
    });
  }

  Futurevoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Futurevoid addMods(String communityName, List<String> uids) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'mods': uids,
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPost(String communityName) {
    return _post
        .where("communityName", isEqualTo: communityName)
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
}

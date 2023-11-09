// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/storage_repo_provider.dart';
import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/post/repository/add_post_repo.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/comment.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final postControlerProvider = StateNotifierProvider<PostControler, bool>((ref) {
  final postReporsitory = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryprovider);

  return PostControler(
    postReporsitory: postReporsitory,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final userPostProvider = StreamProvider.family(
  (ref, List<Community> communities) {
    final postControler = ref.watch(postControlerProvider.notifier);
    return postControler.fetchUserPost(communities);
  },
);
final guestPostProvider = StreamProvider(
  (ref) {
    final postControler = ref.watch(postControlerProvider.notifier);
    return postControler.fetchGuestPost();
  },
);

final getPostByIDProvider = StreamProvider.family((ref, String postid) {
  final postControler = ref.watch(postControlerProvider.notifier);
  return postControler.getPostByID(postid);
});
final getCommentByPostIDProvider = StreamProvider.family((ref, String postid) {
  final postControler = ref.watch(postControlerProvider.notifier);
  return postControler.fetchPostComment(postid);
});

class PostControler extends StateNotifier<bool> {
  final PostReporsitory _postRepository;

  final Ref _ref;

  final StorageRepository _storageRepository;

  PostControler({
    required PostReporsitory postReporsitory,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postReporsitory,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareText(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    state = true;
    String postId = const Uuid().v1();
    DateTime now = DateTime.now();

    // Define a date format pattern
    String pattern = 'dd-MM-yy HH:mm a';
    DateFormat format = DateFormat(pattern);
    String formattedDate = format.format(now);
    DateTime parsedDate = format.parse(formattedDate);

    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: "Text",
      createPost: parsedDate,
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(post);

    _ref.read(userProfileControlerProvider.notifier).updateUserKarma(
          UserKarma.textPost,
        );

    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Posted Succefully");
    });
    Routemaster.of(context).push('/');
  }

  void sharelink(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    state = true;
    String postId = const Uuid().v1();
    DateTime now = DateTime.now();

    // Define a date format pattern
    String pattern = 'dd-MM-yy HH:mm a';
    DateFormat format = DateFormat(pattern);
    String formattedDate = format.format(now);
    DateTime parsedDate = format.parse(formattedDate);

    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: "Link",
      createPost: parsedDate,
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);
    _ref.read(userProfileControlerProvider.notifier).updateUserKarma(
          UserKarma.linkPost,
        );

    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Posted Succefully");
    });
    state = false;
    Routemaster.of(context).push('/');
  }

  void sharePhoto(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required File? file}) async {
    state = true;
    String postId = const Uuid().v1();

    final imageRes = await _storageRepository.storeFile(
        path: "post/${selectedCommunity.name}", id: postId, file: file);
    DateTime now = DateTime.now();

    // Define a date format pattern
    String pattern = 'dd-MM-yy HH:mm a';
    DateFormat format = DateFormat(pattern);
    String formattedDate = format.format(now);
    DateTime parsedDate = format.parse(formattedDate);
    imageRes.fold((l) => showSnackbar(context, l.message), (r) async {
      final user = _ref.read(userProvider)!;
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: "Image",
        createPost: parsedDate,
        awards: [],
        link: r,
      );

      final res = await _postRepository.addPost(post);
      _ref.read(userProfileControlerProvider.notifier).updateUserKarma(
            UserKarma.imagePost,
          );

      res.fold((l) => showSnackbar(context, l.message), (r) {
        showSnackbar(context, "Posted Succefully");
      });
      state = false;
      Routemaster.of(context).push('/');
    });
  }

  Stream<List<Post>> fetchUserPost(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    } else {
      return Stream.value([]);
    }
  }

  Stream<List<Post>> fetchGuestPost() {
    return _postRepository.fetchGuestPosts();
  }

  Stream<List<Comments>> fetchPostComment(String postID) {
    return _postRepository.getAllComments(postID);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);

    _ref.read(userProfileControlerProvider.notifier).updateUserKarma(
          UserKarma.deletePost,
        );

    res.fold((l) => showSnackbar(context, l.message),
        (r) => showSnackbar(context, "Post deleted Successfully"));
  }

  void deletePhoto(Post post, BuildContext context) async {
    final res = await _postRepository.deletePhoto(post);

    res.fold((l) => showSnackbar(context, l.message),
        (r) => showSnackbar(context, "Post deleted Successfully"));
  }

  void upVote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upVote(post, uid);
  }

  void downVote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downVote(post, uid);
  }

  Stream<Post> getPostByID(String postid) {
    return _postRepository.getPostByID(postid);
  }

  void addComment({
    required BuildContext context,
    required String comment,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    final commentid = const Uuid().v1();

    Comments comments = Comments(
      id: commentid,
      text: comment,
      createAt: DateTime.now(),
      postID: post.id,
      username: user.name,
      profilepic: user.profilepic,
      uid: user.uid,
    );

    final res = await _postRepository.addComment(comments);
    _ref.read(userProfileControlerProvider.notifier).updateUserKarma(
          UserKarma.comment,
        );
    res.fold((l) => showSnackbar(context, l.message), (r) {});
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);

    res.fold((l) => showSnackbar(context, l.message), (r) {
      _ref
          .read(userProfileControlerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/storage_repo_provider.dart';
import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/user_profile/repository/user_profile_repo.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControlerProvider =
    StateNotifierProvider<UserProfileControler, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryprovider);

  return UserProfileControler(
    ref: ref,
    storageRepository: storageRepository,
    userProfileRepository: userProfileRepository,
  );
});

final searchUserProvider = StreamProvider.family((ref, String query) {
  return ref.watch(userProfileControlerProvider.notifier).searchUser(query);
});

final getUserPostProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControlerProvider.notifier).getUserPost(uid);
});

class UserProfileControler extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;

  final Ref _ref;

  final StorageRepository _storageRepository;

  UserProfileControler({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editProfile({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: "users/profile",
        id: user.uid,
        file: profileFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => user = user.copyWith(profilepic: r),
      );
    }

    if (bannerFile != null) {
      //community/banner/{communityname}
      final res = await _storageRepository.storeFile(
        path: "users/banner",
        id: user.uid,
        file: bannerFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _userProfileRepository.getUserPost(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: karma.karma + user.karma);

    final res = await _userProfileRepository.updateUserKarma(user);

    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  Stream<List<UserModel>> searchUser(String query) {
    return _userProfileRepository.searchUser(query);
  }
}

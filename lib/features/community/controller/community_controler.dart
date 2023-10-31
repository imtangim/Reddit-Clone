import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Constant/constant.dart';
import 'package:reddit_clone/core/failure.dart';

import 'package:reddit_clone/core/storage_repo_provider.dart';

import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/community/repository/community_repo.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunityProvider = StreamProvider((ref) {
  final communityControler = ref.watch(communityControlerProvider.notifier);
  return communityControler.getUserCommunity();
});
final getCommunityPostProvider =
    StreamProvider.family((ref, String communityName) {
  return ref
      .read(communityControlerProvider.notifier)
      .getCommunityPost(communityName);
});
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControlerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControlerProvider.notifier).searchCommunity(query);
});

final communityControlerProvider =
    StateNotifierProvider<CommunityControler, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryprovider);

  return CommunityControler(
    communityRepository: communityRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

class CommunityControler extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;

  final Ref _ref;

  final StorageRepository _storageRepository;

  CommunityControler({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? "";
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);

    state = false;

    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Community Created Successfully");
      Routemaster.of(context).pop();
    });
  }

  void joinOrleaveCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) {
        if (community.members.contains(user.uid)) {
          showSnackbar(context, "Community left Successfully");
        } else {
          showSnackbar(context, "Community Join Successfully");
        }
      },
    );
  }

  Stream<List<Community>> getUserCommunity() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(
      {required Community community,
      required File? profileFile,
      required File? bannerFile,
      required BuildContext context}) async {
    state = true;
    if (profileFile != null) {
      //community/profile/{communityname}
      final res = await _storageRepository.storeFile(
        path: "community/profile",
        id: community.name,
        file: profileFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      //community/banner/{communityname}
      final res = await _storageRepository.storeFile(
        path: "community/bannerfile",
        id: community.name,
        file: bannerFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }
    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Post>> getCommunityPost(String communityName) {
    return _communityRepository.getCommunityPost(communityName);
  }
}

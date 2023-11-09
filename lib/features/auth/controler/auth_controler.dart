import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/auth/repository/auth_repo.dart';
import 'package:reddit_clone/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControlerProvider = StateNotifierProvider<AuthControler, bool>(
  (ref) => AuthControler(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateChangeProvider = StreamProvider((ref) {
  final authcontroller = ref.watch(authControlerProvider.notifier);

  return authcontroller.authStateChange;
});

final getuserDataProvider = StreamProvider.family((ref, String uid) {
  final authcontroller = ref.watch(authControlerProvider.notifier);
  return authcontroller.getUserData(uid);
});

class AuthControler extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthControler({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signinWithGoogle(isFromLogin);
    state = false;
    user.fold(
      (l) => showSnackbar(context, l.message),
      (usermodel) =>
          _ref.read(userProvider.notifier).update((state) => usermodel),
    );
  }

  void signinAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signinAsGuest();
    state = false;
    user.fold(
      (l) => showSnackbar(context, l.message),
      (usermodel) =>
          _ref.read(userProvider.notifier).update((state) => usermodel),
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logout() async {
    _authRepository.logout();
  }
}

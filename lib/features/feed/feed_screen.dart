import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    final isGuest = !user.isAuthenticated;

    if (!isGuest) {
      return ref.watch(userCommunityProvider).when(
            data: (communities) {
              return ref.watch(userPostProvider(communities)).when(
                    data: (data) {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final post = data[index];
                          return PostCard(post: post, clicked: false);
                        },
                      );
                    },
                    error: (error, stackTrace) =>
                        Errortext(e: error.toString()),
                    loading: () => const Loader(),
                  );
            },
            error: (error, stackTrace) => Errortext(e: error.toString()),
            loading: () => const Loader(),
          );
    }

    return ref.watch(userCommunityProvider).when(
          data: (communities) {
            return ref.watch(guestPostProvider).when(
                  data: (data) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final post = data[index];
                              return PostCard(post: post, clicked: false);
                            },
                          ),
                        ),
                        // const SignButton()
                      ],
                    );
                  },
                  error: (error, stackTrace) => Errortext(e: error.toString()),
                  loading: () => const Loader(),
                );
          },
          error: (error, stackTrace) => Errortext(e: error.toString()),
          loading: () => const Loader(),
        );
  }
}

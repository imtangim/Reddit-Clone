import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/signinbutton.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityDrawer extends ConsumerWidget {
  const CommunityDrawer({super.key});

  void navigateToCreateCommmunity(BuildContext context) {
    Routemaster.of(context).push("/create-community");
  }

  void navigateToCommmunityScreen(BuildContext context, Community community) {
    Routemaster.of(context).push("/r/${community.name}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    final isGuest = !user.isAuthenticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? const SignButton()
                : ListTile(
                    title: const Text("Create Community"),
                    leading: const Icon(Icons.add),
                    onTap: () => navigateToCreateCommmunity(context),
                  ),
            if (!isGuest)
              ref.watch(userCommunityProvider).when(
                    data: (data) => Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final community = data[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text("r/${community.name}"),
                            onTap: () =>
                                navigateToCommmunityScreen(context, community),
                          );
                        },
                      ),
                    ),
                    error: (error, stackTrace) =>
                        Errortext(e: error.toString()),
                    loading: () => const Loader(),
                  ),

            //3:03:36
          ],
        ),
      ),
    );
  }
}

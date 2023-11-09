import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/Constant/constant.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post.dart';
import 'package:reddit_clone/core/common/signinbutton.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

class ProfileScreen extends ConsumerWidget {
  final String uid;

  const ProfileScreen({required this.uid, super.key});

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push("/profile-edit/$uid");
  }

  void navigateToChat(BuildContext context, String name) {
    Routemaster.of(context).push("/chatpage/$uid/$name");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    final isGuest = !user.isAuthenticated;
    return Scaffold(
      body: ref.watch(getuserDataProvider(uid)).when(
            data: (userData) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 250,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            userData.banner,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding:
                              const EdgeInsets.all(20).copyWith(bottom: 70),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(userData.profilepic),
                            radius: 35,
                          ),
                        ),
                        if (!isGuest)
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20),
                            child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                ),
                              ),
                              onPressed: () => navigateToEditUser(context),
                              child: const Text("Edit Profile"),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "u/${userData.name}",
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isGuest)
                              user.uid != uid
                                  ? ElevatedButton(
                                      onPressed: () => navigateToChat(
                                          context, userData.name),
                                      child: const Text("Message"),
                                    )
                                  : const SizedBox(),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("${userData.karma} Karma"),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (userData.awards.isNotEmpty) ...[
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: 25,
                            width: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: userData.awards.length,
                              itemBuilder: (context, index) {
                                final imagelink = userData.awards[index];
                                return Image.asset(
                                  Constants.awards[imagelink]!,
                                  height: 5,
                                );
                              },
                            ),
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                        ],
                      ]),
                    ),
                  ),
                ];
              },
              body: isGuest
                  ? const Center(child: SizedBox(child: SignButton()))
                  : ref.watch(getUserPostProvider(uid)).when(
                        data: (data) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final post = data[index];
                              return PostCard(
                                post: post,
                                clicked: false,
                              );
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return Errortext(e: error.toString());
                        },
                        loading: () => const Loader(),
                      ),
            ),
            error: (error, stackTrace) {
              return Errortext(e: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}

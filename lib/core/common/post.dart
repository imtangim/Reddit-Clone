import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/core/Constant/constant.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/signinbutton.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/theme/pallet.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final bool clicked;
  final Post post;
  const PostCard({required this.post, required this.clicked, super.key});

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(postControlerProvider.notifier).deletePost(post, context);
  }

  void deletePhoto(WidgetRef ref, BuildContext context) {
    ref.read(postControlerProvider.notifier).deletePhoto(post, context);
  }

  void upvotePost(WidgetRef ref) {
    ref.read(postControlerProvider.notifier).upVote(post);
  }

  void downvotePost(WidgetRef ref) {
    ref.read(postControlerProvider.notifier).downVote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) {
    ref
        .read(postControlerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push("/u/${post.uid}");
  }

  void navigateToCommunityProfile(BuildContext context, String communityName) {
    Routemaster.of(context).push("/r/$communityName");
  }

  void navigateToCommentScreen(BuildContext context, String postid) {
    Routemaster.of(context).push("/post/$postid//comments");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'Image';
    final isTypeLink = post.type == 'Link';
    final isTypeText = post.type == 'Text';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 2),
          child: Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => navigateToCommunityProfile(
                                          context, post.communityName),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          post.communityProfilePic,
                                        ),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () =>
                                                navigateToCommunityProfile(
                                                    context,
                                                    post.communityName),
                                            child: Text(
                                              "r/${post.communityName}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                navigateToUserProfile(context),
                                            child: Text(
                                              "u/${post.username}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (post.awards.isNotEmpty) ...[
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              height: 25,
                                              width: 100,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: post.awards.length,
                                                itemBuilder: (context, index) {
                                                  final imagelink =
                                                      post.awards[index];
                                                  return Image.asset(
                                                    Constants
                                                        .awards[imagelink]!,
                                                    height: 5,
                                                  );
                                                },
                                              ),
                                            )
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                    onPressed: isGuest
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                backgroundColor: Colors.grey
                                                    .withOpacity(0.1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const SizedBox(
                                                  child: SignButton(),
                                                ),
                                              ),
                                            );
                                          }
                                        : () {
                                            if (post.type == "Image") {
                                              deletePhoto(ref, context);
                                            }
                                            deletePost(ref, context);
                                          },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Pallete.redColor,
                                    ),
                                  )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    post.link!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (isTypeLink)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10,
                                ),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor: Colors.grey
                                                      .withOpacity(0.1),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const SizedBox(
                                                    child: SignButton(),
                                                  ),
                                                ),
                                              );
                                            }
                                          : () => upvotePost(ref),
                                      icon: Icon(
                                        Constants.up,
                                        size: 25,
                                        color: post.upvotes.contains(user.uid)
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}",
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor: Colors.grey
                                                      .withOpacity(0.1),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const SizedBox(
                                                    child: SignButton(),
                                                  ),
                                                ),
                                              );
                                            }
                                          : () => downvotePost(ref),
                                      icon: Icon(
                                        Constants.down,
                                        size: 25,
                                        color: post.downvotes.contains(user.uid)
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      navigateToCommentScreen(context, post.id),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.comment,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        clicked == false
                                            ? "${post.commentCount == 0 ? 'Comment' : post.commentCount}"
                                            : "${post.commentCount}",
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                    ],
                                  ),
                                ),
                                ref
                                    .watch(
                                      getCommunityByNameProvider(
                                          post.communityName),
                                    )
                                    .when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: isGuest
                                                ? () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          Dialog(
                                                        backgroundColor: Colors
                                                            .grey
                                                            .withOpacity(0.1),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const SizedBox(
                                                          child: SignButton(),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : () {
                                                    if (post.type == "Image") {
                                                      deletePhoto(ref, context);
                                                    }
                                                    deletePost(ref, context);
                                                  },
                                            icon: const Icon(
                                              Icons
                                                  .admin_panel_settings_rounded,
                                            ),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                      error: (error, stackTrace) => Errortext(
                                        e: error.toString(),
                                      ),
                                      loading: () => const Loader(),
                                    ),
                                IconButton(
                                  onPressed: isGuest
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor:
                                                  Colors.grey.withOpacity(0.1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const SizedBox(
                                                child: SignButton(),
                                              ),
                                            ),
                                          );
                                        }
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: GridView.builder(
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 6),
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: user.awards.isEmpty
                                                      ? 1
                                                      : user.awards.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final awards = user
                                                            .awards.isEmpty
                                                        ? ""
                                                        : user.awards[index];
                                                    // print(user.awards[index]);

                                                    return user.awards.isEmpty
                                                        ? const Center(
                                                            child:
                                                                Text("Empty"))
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: InkWell(
                                                              onTap: () =>
                                                                  awardPost(
                                                                      ref,
                                                                      awards,
                                                                      context),
                                                              child:
                                                                  Image.asset(
                                                                Constants
                                                                        .awards[
                                                                    awards]!,
                                                              ),
                                                            ),
                                                          );
                                                    // return SizedBox();
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  icon: const Icon(Icons.card_giftcard_rounded),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post.dart';
import 'package:reddit_clone/core/common/signinbutton.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widgets/comment_card.dart';
import 'package:reddit_clone/models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postid;
  const CommentScreen({required this.postid, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentControler = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool showTextField = true;

  @override
  void initState() {
    super.initState();

    // Add a listener to the scroll controller to detect scroll position.
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // User is scrolling up, hide the TextField.
        setState(() {
          showTextField = false;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // User is scrolling down, show the TextField.
        setState(() {
          showTextField = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    commentControler.dispose();
  }

  void addComment(Post post) {
    ref.read(postControlerProvider.notifier).addComment(
        context: context, comment: commentControler.text.trim(), post: post);
    setState(() {
      commentControler.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIDProvider(widget.postid)).when(
            data: (data) {
              return SizedBox(
                height: double.infinity,
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.99,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(
                              height:
                                  MediaQuery.of(context).size.height * 0.99),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: PostCard(post: data, clicked: true),
                              ),
                              ref
                                  .watch(
                                      getCommentByPostIDProvider(widget.postid))
                                  .when(
                                    data: (data) {
                                      return Expanded(
                                        child: ListView.builder(
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount: data.length,
                                          itemBuilder: (context, index) {
                                            final comment = data[index];

                                            return CommentCard(
                                                comments: comment);
                                          },
                                        ),
                                      );
                                    },
                                    error: (error, stackTrace) {
                                      return Errortext(e: error.toString());
                                    },
                                    loading: () => const Loader(),
                                  ),
                              isGuest
                                  ? const SizedBox(
                                      child: SignButton(),
                                    )
                                  : showTextField
                                      ? SizedBox(
                                          child: TextField(
                                            onSubmitted: (value) =>
                                                addComment(data),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              fillColor: Colors.grey,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              hintText:
                                                  "What are your thoughts?",
                                              hintStyle: const TextStyle(
                                                  color: Colors.black),
                                              filled: true,
                                              suffixIcon: IconButton(
                                                onPressed: () =>
                                                    addComment(data),
                                                icon: const Icon(
                                                  Icons.send,
                                                  color: Colors.black,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                            controller: commentControler,
                                          ),
                                        )
                                      : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return Errortext(e: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reddit_clone/core/common/chat_buddle.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/message/controler/message_controler.dart';
import 'package:reddit_clone/models/message_model.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String name;
  final String uid;
  const ChatPage({required this.uid, required this.name, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  void sendMessage(
    TextEditingController message,
    BuildContext context,
    UserModel reciver,
  ) async {
    if (message.text.isNotEmpty) {
      ref.read(messageControlerProvider.notifier).sendMessage(
            context: context,
            recieverUid: widget.uid,
            recieverProfilepic: reciver.profilepic,
            text: message.text.trim(),
          );
    }
  }

  bool hide = false;

  String calculateTimeDifference(String dateString) {
    final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss.S");
    final parsedDate = inputFormat.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(parsedDate);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 365) {
      return '${difference.inDays} days ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years years ago';
    }
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Navigator.of(context).pop();
    Routemaster.of(context).push("/u/$uid");
  }

  void deletePost(WidgetRef ref, BuildContext context, MessageModel message) {
    Navigator.of(context).pop();
    ref.read(messageControlerProvider.notifier).deleteMessage(message, context);
  }

  // final name = ref.read(getuserDataProvider.);

  @override
  Widget build(BuildContext context) {
    return ref.watch(getuserDataProvider(widget.uid)).when(
          data: (data) {
            return Scaffold(
              appBar: AppBar(
                title: Text(data.name),
                actions: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(data.profilepic),
                                  radius: 50,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  data.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        navigateToUserProfile(
                                            context, data.uid);
                                      },
                                      icon: const Icon(
                                        Icons.account_circle,
                                        size: 40,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(getUserMessageProvider(
                                                widget.uid))
                                            .whenData((value) {
                                          deletePost(
                                            ref,
                                            context,
                                            value.first,
                                          );
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.info),
                  ),
                ],
              ),
              body: ref.watch(getuserDataProvider(widget.uid)).when(
                    data: (data) {
                      final reciver = data;
                      // print(data);
                      return Column(
                        children: [
                          ref.watch(getUserMessageProvider(widget.uid)).when(
                                data: (data) {
                                  // print(data);
                                  return Expanded(
                                    child: ListView(
                                      shrinkWrap: true,
                                      reverse: true,
                                      children: data
                                          .map(
                                            (document) => _buildMessageItem(
                                              document,
                                              ref,
                                              reciver,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                },
                                error: (error, stackTrace) {
                                  return Errortext(e: error.toString());
                                },
                                loading: () => const Loader(),
                              ),
                          TextField(
                            controller: messageController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabled: true,
                              hintText: "Enter messages",
                              suffix: IconButton(
                                onPressed: () {
                                  sendMessage(
                                      messageController, context, reciver);
                                  messageController.clear();
                                },
                                icon: const Icon(
                                  Icons.send,
                                  size: 40,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                    error: (error, stackTrace) {
                      return Errortext(e: error.toString());
                    },
                    loading: () => const Loader(),
                  ),
            );
          },
          error: (error, stackTrace) {
            return Errortext(e: error.toString());
          },
          loading: () => const Loader(),
        );
  }

  Widget _buildMessageItem(
    MessageModel message,
    WidgetRef ref,
    UserModel reciever,
  ) {
    final user = ref.watch(userProvider)!;

    //align message to the right if the sender is current user , otherwise left

    var alignment = (message.senderUID == user.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var align = (message.senderUID == user.uid)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
    final dateString = message.sentAT.toString();
    final timeDifference = calculateTimeDifference(dateString);
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      alignment: alignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: align,
        children: [
          Column(
            crossAxisAlignment: message.senderUID != user.uid
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (message.senderUID == user.uid)
                    hide == true
                        ? Column(
                            children: [
                              Text(
                                message.senderUID == user.uid
                                    ? user.name
                                    : reciever.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                timeDifference,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  if (message.senderUID != user.uid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          message.senderUID == user.uid
                              ? user.profilepic
                              : reciever.profilepic,
                        ),
                        radius: 15,
                      ),
                    ),
                  InkWell(
                    onLongPress: () {
                      setState(() {
                        hide = !hide;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChatBubble(
                        message: message.message,
                        leftOrRight: message.senderUID != user.uid,
                      ),
                    ),
                  ),
                  if (message.senderUID == user.uid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          message.senderUID == user.uid
                              ? user.profilepic
                              : reciever.profilepic,
                        ),
                        radius: 15,
                      ),
                    ),
                  if (message.senderUID != user.uid)
                    hide == true
                        ? Column(
                            children: [
                              Text(
                                message.senderUID == user.uid
                                    ? user.name
                                    : reciever.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                timeDifference,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

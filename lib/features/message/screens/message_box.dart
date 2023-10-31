import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';

import 'package:reddit_clone/features/message/controler/message_controler.dart';
import 'package:routemaster/routemaster.dart';

class MessageBox extends ConsumerStatefulWidget {
  const MessageBox({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
  Map<String, Map<String, dynamic>> resultMap = {};
  void navigateToChat(BuildContext context, String name, String uid) {
    Routemaster.of(context).push("/chatpage/$uid/$name");
  }

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

  @override
  void initState() {
    super.initState();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;
    return Scaffold(
      body: ref.watch(fetchmessageProvider(user.uid)).when(
            data: (data) {
              if (data.isNotEmpty) {
                for (var i = 0; i < data.length; i++) {
                  resultMap[data[i].recieverUID] = {
                    "message": data[i].message,
                    "profile": data[i].recieverProfilePic,
                    "reciverUID": data[i].recieverUID,
                    "time": data[i].sentAT
                  };
                }
              }
              return ListView.separated(
                itemCount: resultMap.length,
                separatorBuilder: (context, index) =>
                    const Divider(), // Add a divider between items
                itemBuilder: (context, index) {
                  final List<String> keys = resultMap.keys.toList();
                  final String recieverUID = keys[index];
                  final Map entry = resultMap[recieverUID]!;

                  final dateString = entry["time"].toString();
                  final timeDifference = calculateTimeDifference(dateString);

                  return ref.watch(getuserDataProvider(recieverUID)).when(
                        data: (data) {
                          return ListTile(
                            onTap: () {
                              navigateToChat(context, recieverUID, recieverUID);
                            },
                            title: Text(data.name),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry["message"]),
                                Text(timeDifference),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(entry["profile"]),
                              radius: 26,
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return Errortext(e: error.toString());
                        },
                        loading: () => const Loader(),
                      );
                },
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

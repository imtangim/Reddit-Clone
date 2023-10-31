import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reddit_clone/models/comment.dart';
import 'package:routemaster/routemaster.dart';

class CommentCard extends ConsumerWidget {
  final Comments comments;
  const CommentCard({required this.comments, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final dateString = comments.createAt.toString();
    final timeDifference = calculateTimeDifference(dateString);

    void navigateToUserProfile(BuildContext context) {
      Routemaster.of(context).push("/u/${comments.uid}");
    }

    // print(comments.createAt);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => navigateToUserProfile(context),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(comments.profilepic),
                  radius: 20,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => navigateToUserProfile(context),
                        child: Text(
                          'u/${comments.username}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Text(
                        comments.text,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.reply,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Reply",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  timeDifference,
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

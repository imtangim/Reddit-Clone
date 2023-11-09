import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';

import 'package:routemaster/routemaster.dart';

class SearchPersondelegates extends SearchDelegate {
  final WidgetRef ref;

  SearchPersondelegates(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchUserProvider(query)).when(
          data: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final user = data[index];
              return user.isAuthenticated
                  ? ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilepic),
                      ),
                      title: Text('u/${user.name}'),
                      onTap: () => navigateToUserScreen(context, user.uid),
                    )
                  : const SizedBox();
            },
          ),
          error: (error, stackTrace) => Errortext(e: error.toString()),
          loading: () => const Loader(),
        );
  }

  void navigateToUserScreen(BuildContext context, String uid) {
    Routemaster.of(context).push("/u/$uid");
  }
}

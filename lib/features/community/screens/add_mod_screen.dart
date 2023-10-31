import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';

class AddModScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModScreen({
    required this.name,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModScreenState();
}

class _AddModScreenState extends ConsumerState<AddModScreen> {
  Set<String> uids = {};
  int counter = 0;
  void addUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void save() {
    ref
        .read(communityControlerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) => ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (context, index) {
                final member = community.members[index];

                return ref.watch(getuserDataProvider(member)).when(
                      data: (userData) {
                        if (community.mods.contains(member) && counter == 0) {
                          uids.add(member);
                        }
                        counter++;
                        return CheckboxListTile(
                          title: Text(userData.name),
                          value: uids.contains(userData.uid),
                          onChanged: (value) {
                            if (value!) {
                              addUids(userData.uid);
                            } else {
                              removeUids(userData.uid);
                            }
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          Errortext(e: error.toString()),
                      loading: () => const Loader(),
                    );
              },
            ),
            error: (error, stackTrace) => Errortext(e: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}

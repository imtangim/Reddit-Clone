import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';

class CreateCommunity extends ConsumerStatefulWidget {
  const CreateCommunity({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityState();
}

class _CreateCommunityState extends ConsumerState<CreateCommunity> {
  TextEditingController communityNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createcommunity() {
    ref
        .read(communityControlerProvider.notifier)
        .createCommunity(communityNameController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isloading = ref.watch(communityControlerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a community"),
      ),
      body: isloading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Community name"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: communityNameController,
                    decoration: const InputDecoration(
                      hintText: "Community Name",
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 21,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => createcommunity(),
                    child: const Text(
                      "Create Communnity",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

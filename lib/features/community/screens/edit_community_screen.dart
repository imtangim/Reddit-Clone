import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/Constant/constant.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallet.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({required this.name, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectbannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(communityControlerProvider.notifier).editCommunity(
          community: community,
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControlerProvider);
    final currrentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (data) => Scaffold(
            ///data means comunity data
            // ignore: deprecated_member_use
            backgroundColor: currrentTheme.backgroundColor,
            appBar: AppBar(
              title: const Text("Edit Community"),
              actions: [
                TextButton(
                  onPressed: () => save(data),
                  child: const Text("Save"),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: selectbannerImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color: currrentTheme
                                      .textTheme.bodyMedium!.color!,
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: bannerFile != null
                                        ? Image.file(bannerFile!)
                                        : data.banner.isEmpty ||
                                                data.banner ==
                                                    Constants.bannerDefault
                                            ? const Center(
                                                child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                ),
                                              )
                                            : Image.network(data.banner),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: GestureDetector(
                                  onTap: selectProfileImage,
                                  child: profileFile != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(profileFile!),
                                          radius: 32,
                                        )
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(data.avatar),
                                          radius: 32,
                                        ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => Errortext(e: error.toString()),
        );
  }
}

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/community/controller/community_controler.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallet.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({required this.type, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleControler = TextEditingController();
  final discriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  List<Community> communities = [];
  Community? selectedComunity;

  @override
  void dispose() {
    super.dispose();
    titleControler.dispose();
    discriptionController.dispose();
    linkController.dispose();
  }

  void selectbannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == "Image" &&
        bannerFile != null &&
        titleControler.text.isNotEmpty) {
      ref.read(postControlerProvider.notifier).sharePhoto(
            context: context,
            title: titleControler.text.trim(),
            selectedCommunity: selectedComunity ?? communities[0],
            file: bannerFile,
          );
    } else if (widget.type == "Text" && titleControler.text.isNotEmpty) {
      ref.read(postControlerProvider.notifier).shareText(
          context: context,
          title: titleControler.text.trim(),
          selectedCommunity: selectedComunity ?? communities[0],
          description: discriptionController.text.trim());
    } else if (widget.type == "Link" &&
        linkController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControlerProvider.notifier).sharelink(
            context: context,
            title: titleControler.text.trim(),
            selectedCommunity: selectedComunity ?? communities[0],
            link: linkController.text.trim(),
          );
    } else {
      showSnackbar(context, "Please enter valid fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'Image';
    final isTypeLink = widget.type == 'Link';
    final isTypeText = widget.type == 'Text';
    final isLoading = ref.watch(postControlerProvider);

    final currrentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Post ${widget.type}"),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text("Share"),
          )
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleControler,
                    decoration: InputDecoration(
                        enabled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        hintText: "Enter Title Here",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectbannerImage,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: currrentTheme.textTheme.bodyMedium!.color!,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bannerFile != null
                              ? Image.file(bannerFile!)
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      controller: discriptionController,
                      decoration: InputDecoration(
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          hintText: "Enter description here",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18)),
                      maxLines: 5,
                      // maxLength: 300,
                    ),
                  if (isTypeLink)
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          hintText: "Enter Link here",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18)),
                      maxLines: 5,
                      // maxLength: 300,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Select Community"),
                  ),
                  ref.watch(userCommunityProvider).when(
                        data: (data) {
                          communities = data;

                          if (data.isEmpty) {
                            return const SizedBox();
                          }

                          return DropdownButton(
                            value: selectedComunity ?? data[0],
                            items: data
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e.name)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedComunity = value;
                              });
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return Errortext(e: error.toString());
                        },
                        loading: () => const Loader(),
                      )
                ],
              ),
            ),
    );
  }
}

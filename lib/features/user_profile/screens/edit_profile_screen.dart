import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/Constant/constant.dart';
import 'package:reddit_clone/core/common/error.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/util.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/theme/pallet.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({required this.uid, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  late TextEditingController nameController;

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

  void save() {
    ref.read(userProfileControlerProvider.notifier).editProfile(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          name: nameController.text.trim(),
        );
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControlerProvider);
    final currrentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getuserDataProvider(widget.uid)).when(
          data: (data) => Scaffold(
            ///data means comunity data
            // ignore: deprecated_member_use
            backgroundColor: currrentTheme.backgroundColor,
            appBar: AppBar(
              title: const Text("Edit Profile"),
              actions: [
                TextButton(
                  onPressed: save,
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
                                              NetworkImage(data.profilepic),
                                          radius: 32,
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                              enabled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              filled: true,
                              hintText: "Name",
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18)),
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

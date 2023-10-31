import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/theme/pallet.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push("/add-post/$type");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeight = 120;
    double iconSize = 120;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => navigateToType(context, "Image"),
          child: SizedBox(
            height: cardHeight,
            width: cardHeight,
            child: Card(
              color: currentTheme.colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: iconSize / 2,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToType(context, "Text"),
          child: SizedBox(
            height: cardHeight,
            width: cardHeight,
            child: Card(
              color: currentTheme.colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                child: Icon(
                  CupertinoIcons.pencil_ellipsis_rectangle,
                  size: iconSize / 2,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToType(context, "Link"),
          child: SizedBox(
            height: cardHeight,
            width: cardHeight,
            child: Card(
              color: currentTheme.colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                child: Icon(
                  Icons.add_link_outlined,
                  size: iconSize / 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/Constant/constant.dart';
import 'package:reddit_clone/features/auth/controler/auth_controler.dart';
import 'package:reddit_clone/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clone/features/home/delegates/search_person_delegate.dart';
import 'package:reddit_clone/features/home/drawer/community_drawer.dart';
import 'package:reddit_clone/features/home/drawer/profile_drawer.dart';
import 'package:reddit_clone/theme/pallet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  int _page = 0;

  void onPageChanged(int page) {
    if (kDebugMode) {
      print("Hi $_page");
    }
    setState(() {
      _page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              displayDrawer(context);
            },
            icon: const Icon(Icons.menu),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchPersondelegates(ref));
            },
            icon: const Icon(Icons.person_search_rounded),
          ),
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunitydelegates(ref));
            },
            icon: const Icon(Icons.groups_2_rounded),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => displayEndDrawer(context),
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilepic),
              ),
            );
          }),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: const CommunityDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      bottomNavigationBar: isGuest
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.colorScheme.background,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded)),
                BottomNavigationBarItem(icon: Icon(Icons.add_rounded)),
                BottomNavigationBarItem(icon: Icon(Icons.message)),
              ],
              onTap: onPageChanged,
              currentIndex: _page,
            ),
    );
  }
}

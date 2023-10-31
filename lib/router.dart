//loggedout route
import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screens/login.dart';
import 'package:reddit_clone/features/community/screens/add_mod_screen.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/screen/homescreen.dart';
import 'package:reddit_clone/features/message/screens/chat_page.dart';
import 'package:reddit_clone/features/post/screens/comment_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/user_profile.dart';
import 'package:routemaster/routemaster.dart';

import 'features/post/screens/add_post_type_screen.dart';

final loggedoutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: LoginScreen()),
  },
);

//loggedin route

final loggedinRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community': (_) => const MaterialPage(child: CreateCommunity()),
    '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
            name: route.pathParameters['name']!,
          ),
        ),
    "/mod-tools/:name": (route) => MaterialPage(
            child: ModToolsScreen(
          name: route.pathParameters["name"]!,
        )),
    "/edit-tools/:name": (route) => MaterialPage(
          child: EditCommunityScreen(
            name: route.pathParameters["name"]!,
          ),
        ),
    "/add-mods/:name": (route) => MaterialPage(
          child: AddModScreen(
            name: route.pathParameters["name"]!,
          ),
        ),
    "/u/:uid": (route) => MaterialPage(
          child: ProfileScreen(
            uid: route.pathParameters["uid"]!,
          ),
        ),
    "/profile-edit/:uid": (route) => MaterialPage(
          child: EditProfileScreen(
            uid: route.pathParameters["uid"]!,
          ),
        ),
    "/add-post/:type": (route) => MaterialPage(
          child: AddPostTypeScreen(
            type: route.pathParameters["type"]!,
          ),
        ),
    "/post/:PostId/comments": (route) => MaterialPage(
          child: CommentScreen(
            postid: route.pathParameters["PostId"]!,
          ),
        ),
    "/chatpage/:uid/:name": (route) => MaterialPage(
            child: ChatPage(
          uid: route.pathParameters["uid"]!,
          name: route.pathParameters["name"]!,
        )),
  },
);

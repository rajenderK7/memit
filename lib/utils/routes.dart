import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/collection_notes_page.dart';
import 'package:memit/pages/collections_page.dart';
import 'package:memit/pages/create_page.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/pages/main_scaffold.dart';
import 'package:memit/pages/onboarding_page.dart';
import 'package:memit/pages/read_note_page.dart';
import 'package:memit/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  home -> "/"
  collections -> "/collections"

  -- Since `home` and `collections` are on the same level the `collections` 
  -- route can be nested under the `home` route.

  -- For `home` and `collection` routes the `bottomNavbar` shall be static, 
  -- hence, we can use a `ShellRoute` from `go_router` package.

  settings -> "/settings"
  create -> "/create"
  readNote -> "/readNote"
*/

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: "collections",
              builder: (context, state) => const CollectionsPage(),
            ),
          ],
        ),
      ],
      builder: (context, state, child) => MainScaffold(
        child: child,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/settings",
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: "/create",
        builder: (context, state) {
          Note? note = state.extra != null ? state.extra as Note : null;
          return CreatePage(
            note: note,
          );
        }),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/readNote/:id",
      builder: (context, state) => ReadNotePage(
        id: int.parse(
          state.params["id"] ?? "",
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/collectionNotes/:id/:title",
      builder: (context, state) => CollectionNotesPage(
        collectionId: int.parse(state.params["id"]!),
        collectionTitle: state.params["title"]!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/onboarding",
      builder: (context, state) => const OnboardingPage(),
    )
  ],
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    bool onBoarded = prefs.getBool("onBoarded") ?? false;
    if (!onBoarded && state.subloc == "/") {
      return "/onboarding";
    }
    return null;
  },
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/pages/main_scaffold.dart';
import 'package:memit/pages/settings_page.dart';

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
              builder: (context, state) => Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.red,
              ),
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
      builder: (context, state) => Container(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/readNote/:id",
      builder: (context, state) => Container(),
    ),
  ],
);

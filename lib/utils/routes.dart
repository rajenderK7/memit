import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/collection_notes_page.dart';
import 'package:memit/pages/collections_page.dart';
import 'package:memit/pages/create_page.dart';
import 'package:memit/pages/forgot_passcode_page.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/pages/main_scaffold.dart';
import 'package:memit/pages/onboarding_page.dart';
import 'package:memit/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final globalNavigatorProvider = Provider((ref) => _rootNavigatorKey);

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
      builder: (context, state, child) => HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: MainScaffold(
          child: child,
        ),
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
      },
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
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/forgot_passcode",
      builder: (context, state) => const ForgotPasscodePage(),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/shared/memit_app_bar.dart';
import 'package:memit/widgets/bottom_navbar.dart';
import 'package:memit/widgets/memit_drawer.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemitDrawer(),
      appBar: const MemitAppBar(),
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push("/create"),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}

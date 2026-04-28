import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_drawer.dart';
import 'branches.dart';
import 'identify_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: Rotalar.anasayfaPath,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          key: AppDrawer.key,
          drawer: AppDrawer.build(context),
          body: Container(
            key: ValueKey('body_${context.locale.languageCode}'),
            child: navigationShell,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIkon(context, navigationShell, 0, Icons.home),
                  _navIkon(
                      context, navigationShell, 1, Icons.add_circle_outline),
                  _navIkon(context, navigationShell, 2, Icons.settings),
                  _navIkon(context, navigationShell, 3, Icons.info_outline),
                ],
              ),
            ),
          ),
        );
      },
      branches: branches,
    ),
  ],
);

Widget _navIkon(BuildContext context, StatefulNavigationShell shell,
    int index, IconData icon) {
  final aktif = shell.currentIndex == index;
  return IconButton(
    icon: Icon(
      icon,
      color: aktif
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    ),
    iconSize: aktif ? 32 : 28,
    onPressed: () {
      AppDrawer.close();
      shell.goBranch(index, initialLocation: shell.currentIndex == index);
    },
  );
}

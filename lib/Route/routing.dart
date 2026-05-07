import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/Ayarlar/Dil/dil.dart';
import '../screens/Ayarlar/ayarlar.dart';
import '../screens/Hakkında/hakkinda.dart';
import '../screens/KumandaEkle/kumanda_ekle.dart';
import '../screens/OdaEkle/oda_ekle.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import 'branches.dart';
import 'identify_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: Rotalar.anasayfaPath,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        final tp = context.watch<ThemeProvider>();
        return Scaffold(
          backgroundColor: AppColors.background,
          body: navigationShell,
          bottomNavigationBar: CustomBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            ),
            themeProvider: tp,
          ),
        );
      },
      branches: branches,
    ),

    // Detay rotalari (shell disinda — bottom-nav gizli)
    GoRoute(
      path: Rotalar.kumandaEklePath,
      name: Rotalar.kumandaEkleName,
      pageBuilder: (c, s) =>
          MaterialPage(key: s.pageKey, child: const KumandaEkle()),
    ),
    GoRoute(
      path: Rotalar.odaEklePath,
      name: Rotalar.odaEkleName,
      pageBuilder: (c, s) =>
          MaterialPage(key: s.pageKey, child: const OdaEkle()),
    ),
    GoRoute(
      path: Rotalar.ayarlarPath,
      name: Rotalar.ayarlarName,
      pageBuilder: (c, s) =>
          MaterialPage(key: s.pageKey, child: const Ayarlar()),
      routes: [
        GoRoute(
          path: Rotalar.dilPath,
          name: Rotalar.dilName,
          pageBuilder: (c, s) =>
              MaterialPage(key: s.pageKey, child: const Dil()),
        ),
      ],
    ),
    GoRoute(
      path: Rotalar.hakkindaPath,
      name: Rotalar.hakkindaName,
      pageBuilder: (c, s) =>
          MaterialPage(key: s.pageKey, child: const Hakkinda()),
    ),
  ],
);

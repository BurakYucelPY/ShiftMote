import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/Anasayfa/anasayfa.dart';
import '../screens/Favoriler/favoriler.dart';
import '../screens/Kumanda/kumanda.dart';
import '../screens/Odalar/OdaDetay/oda_detay.dart';
import '../screens/Odalar/odalar.dart';
import 'identify_routes.dart';

final List<StatefulShellBranch> branches = [
  // BRANCH 0: Anasayfa (alt: kumanda detayi)
  StatefulShellBranch(
    initialLocation: Rotalar.anasayfaPath,
    routes: [
      GoRoute(
        path: Rotalar.anasayfaPath,
        name: Rotalar.anasayfaName,
        pageBuilder: (c, s) =>
            MaterialPage(key: s.pageKey, child: const Anasayfa()),
        routes: [
          GoRoute(
            path: Rotalar.kumandaPath,
            name: Rotalar.kumandaName,
            pageBuilder: (c, s) {
              final id = int.tryParse(s.pathParameters['id'] ?? '0') ?? 0;
              return MaterialPage(
                  key: s.pageKey, child: KumandaSayfasi(kumandaId: id));
            },
          ),
        ],
      ),
    ],
  ),

  // BRANCH 1: Odalar (alt: oda detayi)
  StatefulShellBranch(
    initialLocation: Rotalar.odalarPath,
    routes: [
      GoRoute(
        path: Rotalar.odalarPath,
        name: Rotalar.odalarName,
        pageBuilder: (c, s) =>
            MaterialPage(key: s.pageKey, child: const Odalar()),
        routes: [
          GoRoute(
            path: Rotalar.odaDetayPath,
            name: Rotalar.odaDetayName,
            pageBuilder: (c, s) {
              final id = s.pathParameters['id'] ?? '';
              return MaterialPage(
                  key: s.pageKey, child: OdaDetay(odaId: id));
            },
          ),
        ],
      ),
    ],
  ),

  // BRANCH 2: Favoriler
  StatefulShellBranch(
    initialLocation: Rotalar.favorilerPath,
    routes: [
      GoRoute(
        path: Rotalar.favorilerPath,
        name: Rotalar.favorilerName,
        pageBuilder: (c, s) =>
            MaterialPage(key: s.pageKey, child: const Favoriler()),
      ),
    ],
  ),
];

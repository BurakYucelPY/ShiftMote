import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/Anasayfa/anasayfa.dart';
import '../screens/Ayarlar/ayarlar.dart';
import '../screens/Ayarlar/Dil/dil.dart';
import '../screens/Hakkında/hakkinda.dart';
import '../screens/Kumanda/kumanda.dart';
import '../screens/KumandaEkle/kumanda_ekle.dart';
import 'identify_routes.dart';

final List<StatefulShellBranch> branches = [
  // BRANCH 0: Anasayfa (alt route: Kumanda detayı)
  StatefulShellBranch(
    initialLocation: Rotalar.anasayfaPath,
    routes: [
      GoRoute(
        path: Rotalar.anasayfaPath,
        name: Rotalar.anasayfaName,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Anasayfa(),
        ),
        routes: [
          GoRoute(
            path: Rotalar.kumandaPath, // /anasayfa/kumanda/:id
            name: Rotalar.kumandaName,
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return MaterialPage(
                key: state.pageKey,
                child: Kumanda(kumandaId: id),
              );
            },
          ),
        ],
      ),
    ],
  ),

  // BRANCH 1: KumandaEkle
  StatefulShellBranch(
    initialLocation: Rotalar.kumandaEklePath,
    routes: [
      GoRoute(
        path: Rotalar.kumandaEklePath,
        name: Rotalar.kumandaEkleName,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const KumandaEkle(),
        ),
      ),
    ],
  ),

  // BRANCH 2: Ayarlar (alt route: Dil)
  StatefulShellBranch(
    initialLocation: Rotalar.ayarlarPath,
    routes: [
      GoRoute(
        path: Rotalar.ayarlarPath,
        name: Rotalar.ayarlarName,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Ayarlar(),
        ),
        routes: [
          GoRoute(
            path: Rotalar.dilPath, // /ayarlar/dil
            name: Rotalar.dilName,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const Dil(),
            ),
          ),
        ],
      ),
    ],
  ),

  // BRANCH 3: Hakkında
  StatefulShellBranch(
    initialLocation: Rotalar.hakkindaPath,
    routes: [
      GoRoute(
        path: Rotalar.hakkindaPath,
        name: Rotalar.hakkindaName,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Hakkinda(),
        ),
      ),
    ],
  ),
];

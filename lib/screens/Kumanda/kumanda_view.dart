import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import 'ac_remote.dart';
import 'generic_remote.dart';
import 'kumanda.dart';
import 'projektor_remote.dart';
import 'tv_remote.dart';

class KumandaView extends StatelessWidget {
  const KumandaView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KumandaProvider>();
    final tp = context.watch<ThemeProvider>();

    if (p.yukleniyor) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final hata = p.hata;
    if (hata != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(child: Text(hata)),
      );
    }
    final k = p.kumanda;
    if (k == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(child: Text('kumanda_page.yok'.tr())),
      );
    }

    switch (k.kategoriAnahtari) {
      case 'tv':
        return TvRemote(provider: p, themeProvider: tp);
      case 'klima':
        return AcRemote(provider: p, themeProvider: tp);
      case 'projektor':
        return ProjektorRemote(provider: p, themeProvider: tp);
      default:
        return GenericRemote(provider: p, themeProvider: tp);
    }
  }
}

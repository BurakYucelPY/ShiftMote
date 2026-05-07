import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../db/kumanda_deposu.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/cihaz_aksiyonlari.dart';
import '../../widgets/device_tile.dart';

class Favoriler extends StatefulWidget {
  const Favoriler({super.key});

  @override
  State<Favoriler> createState() => _FavorilerState();
}

class _FavorilerState extends State<Favoriler> {
  List<Kumanda> _favoriler = [];

  @override
  void initState() {
    super.initState();
    _yenile();
    KumandaDeposu.degisim.addListener(_yenile);
  }

  @override
  void dispose() {
    KumandaDeposu.degisim.removeListener(_yenile);
    super.dispose();
  }

  void _yenile() {
    if (!mounted) return;
    setState(() => _favoriler = KumandaDeposu.favoriler());
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('favoriler.baslik'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('${_favoriler.length} ${'favoriler.cihaz'.tr()}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Expanded(
                child: _favoriler.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_outline_rounded,
                                color: AppColors.textSecondary, size: 56),
                            const SizedBox(height: 16),
                            Text('favoriler.bos'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge),
                            const SizedBox(height: 4),
                            Text('favoriler.bos_alt'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _favoriler.length,
                        itemBuilder: (c, i) {
                          final k = _favoriler[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DeviceTile(
                              kumanda: k,
                              onTap: () => context.push(
                                  '${Rotalar.anasayfaPath}/kumanda/${k.id}'),
                              onFavoriteToggle: (v) async {
                                await KumandaDeposu.favoriDegistir(k.id, v);
                              },
                              onRename: () =>
                                  cihazYenidenAdlandir(context, k),
                              onDelete: () => cihazSil(context, k),
                              animationIndex: i,
                              themeProvider: tp,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

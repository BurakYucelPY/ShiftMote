import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/cihaz_aksiyonlari.dart';
import '../../widgets/device_tile.dart';
import '../../widgets/room_card.dart';
import 'anasayfa.dart';

class AnasayfaView extends StatelessWidget {
  const AnasayfaView({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final p = context.watch<AnasayfaProvider>();
    final isClassic = tp.isClassic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('app.baslik'.tr(),
                          style:
                              Theme.of(context).textTheme.headlineLarge),
                    ),
                    _ikonButon(
                      isClassic: isClassic,
                      ikon: Icons.settings_rounded,
                      onTap: () => context.push(Rotalar.ayarlarPath),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(children: [
                  isClassic
                      ? Neumorphic(
                          style: NeuPresets.pressed(
                              depth: -3,
                              intensity: 0.5,
                              radius: AppRadius.lg),
                          child: _cihazCipiIc(context, p.kumandalar.length),
                        )
                      : Container(
                          decoration: ModernPresets.inset(),
                          child: _cihazCipiIc(context, p.kumandalar.length),
                        ),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('anasayfa.odalar'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall),
                    _ekleButon(
                      isClassic: isClassic,
                      onTap: () => context.push(Rotalar.odaEklePath),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 165,
                child: p.odalar.isEmpty
                    ? _bosOdalar(context)
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: p.odalar.length,
                        itemBuilder: (c, i) {
                          final oda = p.odalar[i];
                          return RoomCard(
                            oda: oda,
                            cihazSayisi: p.cihazSayisiOda(oda.id),
                            onTap: () => context
                                .push('${Rotalar.odalarPath}/oda/${oda.id}'),
                            animationIndex: i,
                            themeProvider: tp,
                          );
                        },
                      ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('anasayfa.tum_cihazlar'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall),
                    _ekleButon(
                      isClassic: isClassic,
                      onTap: () => context.push(Rotalar.kumandaEklePath),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: p.kumandalar.isEmpty
                  ? SliverToBoxAdapter(
                      child: _bosCihazlar(context, isClassic))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (c, i) {
                          final k = p.kumandalar[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DeviceTile(
                              kumanda: k,
                              onTap: () => context.push(
                                  '${Rotalar.anasayfaPath}/kumanda/${k.id}'),
                              onFavoriteToggle: (v) =>
                                  p.favoriDegistir(k.id, v),
                              onRename: () =>
                                  cihazYenidenAdlandir(context, k),
                              onDelete: () => cihazSil(context, k),
                              animationIndex: i,
                              themeProvider: tp,
                            ),
                          );
                        },
                        childCount: p.kumandalar.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ikonButon({
    required bool isClassic,
    required IconData ikon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: isClassic
          ? Neumorphic(
              style: NeuPresets.circle(depth: 4),
              child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(ikon, color: AppColors.accent, size: 20)),
            )
          : Container(
              width: 42,
              height: 42,
              decoration: ModernPresets.circleButton(),
              child: Icon(ikon, color: AppColors.accent, size: 20),
            ),
    );
  }

  Widget _cihazCipiIc(BuildContext context, int sayi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.devices_rounded, size: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          '$sayi ${'anasayfa.cihaz'.tr()}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.offWhite),
        ),
      ]),
    );
  }

  Widget _ekleButon({required bool isClassic, required VoidCallback onTap}) {
    final ic = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add_rounded, size: 16, color: AppColors.accent),
        const SizedBox(width: 4),
        Text('genel.ekle'.tr(),
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ]),
    );
    return GestureDetector(
      onTap: onTap,
      child: isClassic
          ? Neumorphic(
              style: NeuPresets.button(depth: 4, radius: AppRadius.md),
              child: ic)
          : Container(
              decoration: ModernPresets.button(radius: AppRadius.md),
              child: ic),
    );
  }

  Widget _bosOdalar(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.meeting_room_outlined,
              color: AppColors.textSecondary, size: 36),
          const SizedBox(height: 8),
          Text('anasayfa.bos_odalar'.tr(),
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _bosCihazlar(BuildContext context, bool isClassic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        isClassic
            ? Neumorphic(
                style: NeuPresets.circlePressed(),
                child: const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(Icons.devices_other_rounded,
                        color: AppColors.textSecondary, size: 28)))
            : Container(
                width: 64,
                height: 64,
                decoration: ModernPresets.circleInset(),
                child: const Icon(Icons.devices_other_rounded,
                    color: AppColors.textSecondary, size: 28)),
        const SizedBox(height: 16),
        Text('anasayfa.bos_cihazlar'.tr(),
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text('anasayfa.bos_cihazlar_alt'.tr(),
            style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

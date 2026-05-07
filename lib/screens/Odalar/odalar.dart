import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../db/kumanda_deposu.dart';
import '../../db/oda_deposu.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/room_card.dart';

class Odalar extends StatefulWidget {
  const Odalar({super.key});

  @override
  State<Odalar> createState() => _OdalarState();
}

class _OdalarState extends State<Odalar> {
  List<Oda> _odalar = [];
  List<Kumanda> _kumandalar = [];

  @override
  void initState() {
    super.initState();
    _yenile();
    OdaDeposu.degisim.addListener(_yenile);
    KumandaDeposu.degisim.addListener(_yenile);
  }

  @override
  void dispose() {
    OdaDeposu.degisim.removeListener(_yenile);
    KumandaDeposu.degisim.removeListener(_yenile);
    super.dispose();
  }

  void _yenile() {
    if (!mounted) return;
    setState(() {
      _odalar = OdaDeposu.tumunu();
      _kumandalar = KumandaDeposu.tumunu();
    });
  }

  int _cihazSayisi(String odaId) =>
      _kumandalar.where((k) => k.odaId == odaId).length;

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('odalar.baslik'.tr(),
                            style:
                                Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                            '${_odalar.length} ${'odalar.oda_alt'.tr()}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(Rotalar.odaEklePath),
                    child: isClassic
                        ? Neumorphic(
                            style: NeuPresets.button(
                                depth: 4, radius: AppRadius.md),
                            child: _ekleIc(context),
                          )
                        : Container(
                            decoration: ModernPresets.button(
                                radius: AppRadius.md),
                            child: _ekleIc(context),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _odalar.isEmpty
                    ? _bosDurum(context)
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: _odalar.length,
                        itemBuilder: (c, i) {
                          final oda = _odalar[i];
                          return RoomCard(
                            oda: oda,
                            cihazSayisi: _cihazSayisi(oda.id),
                            onTap: () => context.push(
                                '${Rotalar.odalarPath}/oda/${oda.id}'),
                            animationIndex: i,
                            themeProvider: tp,
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

  Widget _ekleIc(BuildContext context) => Padding(
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

  Widget _bosDurum(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.meeting_room_outlined,
              color: AppColors.textSecondary, size: 56),
          const SizedBox(height: 16),
          Text('odalar.bos'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('odalar.bos_alt'.tr(),
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

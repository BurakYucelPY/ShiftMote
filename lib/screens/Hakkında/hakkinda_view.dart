import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';

class HakkindaView extends StatelessWidget {
  const HakkindaView({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('hakkinda'.tr())),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Center(
            child: isClassic
                ? Neumorphic(
                    style: NeuPresets.circle(depth: 6),
                    child: const SizedBox(
                        width: 96,
                        height: 96,
                        child: Icon(Icons.settings_remote_rounded,
                            size: 48, color: AppColors.accent)),
                  )
                : Container(
                    width: 96,
                    height: 96,
                    decoration: ModernPresets.circleButton(),
                    child: const Icon(Icons.settings_remote_rounded,
                        size: 48, color: AppColors.accent),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
              child: Text('app.baslik'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 4),
          Center(
              child: Text('${'hakkinda_page.surum'.tr()}: 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 24),
          _kart(context,
              isClassic: isClassic,
              ic: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('hakkinda_page.aciklama'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium),
              )),
          const SizedBox(height: 12),
          _kart(context,
              isClassic: isClassic,
              ic: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.dataset_rounded,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('hakkinda_page.veri_kaynagi'.tr(),
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text('hakkinda_page.irdb_attr'.tr(),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ]),
              )),
          const SizedBox(height: 12),
          _kart(context,
              isClassic: isClassic,
              ic: Padding(
                padding: const EdgeInsets.all(14),
                child: Text('hakkinda_page.not'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              )),
        ],
      ),
    );
  }

  Widget _kart(BuildContext c,
      {required bool isClassic, required Widget ic}) {
    return isClassic
        ? Neumorphic(style: NeuPresets.card(depth: 4), child: ic)
        : Container(decoration: ModernPresets.card(), child: ic);
  }
}
